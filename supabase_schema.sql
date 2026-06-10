-- ===== EventHub Supabase Schema =====
-- Run this in Supabase SQL Editor

-- 1. Profiles (already used by auth, ensure it exists)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    name TEXT NOT NULL DEFAULT '',
    phone TEXT,
    photo_url TEXT,
    role TEXT NOT NULL DEFAULT 'participant' CHECK (role IN ('admin', 'organizer', 'participant')),
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Auto-create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, name, role, photo_url)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'name', ''),
        COALESCE(NEW.raw_user_meta_data->>'role', 'participant'),
        NEW.raw_user_meta_data->>'avatar_url'
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 2. Events
CREATE TABLE IF NOT EXISTS public.events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT NOT NULL DEFAULT '',
    image_url TEXT,
    date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ,
    location TEXT NOT NULL,
    city TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    price DOUBLE PRECISION NOT NULL DEFAULT 0,
    max_participants INT NOT NULL DEFAULT 0,
    current_participants INT NOT NULL DEFAULT 0,
    category TEXT NOT NULL DEFAULT 'conference',
    status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'cancelled', 'completed')),
    organizer_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    organizer_name TEXT,
    is_featured BOOLEAN NOT NULL DEFAULT false,
    rejection_reason TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 3. Bookings
CREATE TABLE IF NOT EXISTS public.bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL REFERENCES public.events(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    event_title TEXT,
    event_image_url TEXT,
    event_date TIMESTAMPTZ,
    event_location TEXT,
    quantity INT NOT NULL DEFAULT 1,
    total_amount DOUBLE PRECISION NOT NULL DEFAULT 0,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'cancelled', 'refunded')),
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 4. Tickets
CREATE TABLE IF NOT EXISTS public.tickets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL REFERENCES public.events(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    booking_id UUID NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
    event_title TEXT,
    event_date TEXT,
    event_location TEXT,
    qr_code TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'used', 'cancelled')),
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 5. Payments
CREATE TABLE IF NOT EXISTS public.payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
    amount DOUBLE PRECISION NOT NULL,
    currency TEXT NOT NULL DEFAULT 'TND',
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
    stripe_payment_intent_id TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 6. Notifications
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    type TEXT NOT NULL DEFAULT 'general' CHECK (type IN ('bookingConfirmation', 'paymentConfirmed', 'eventCancelled', 'eventReminder', 'general')),
    data TEXT,
    is_read BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 7. Favorites
CREATE TABLE IF NOT EXISTS public.favorites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    event_id UUID NOT NULL REFERENCES public.events(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(user_id, event_id)
);

-- ===== Schema Permissions =====
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO anon, authenticated;

-- ===== Row Level Security =====
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.favorites ENABLE ROW LEVEL SECURITY;

-- Profiles: users can read/update their own
CREATE POLICY "users can read own profile"
    ON public.profiles FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "users can update own profile"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = id);

-- Events: anyone can read published, organizer can write
CREATE POLICY "anyone can read published events"
    ON public.events FOR SELECT
    USING (status = 'published' OR auth.uid() = organizer_id);

CREATE POLICY "organizers can insert events"
    ON public.events FOR INSERT
    WITH CHECK (auth.uid() = organizer_id);

CREATE POLICY "organizers can update own events"
    ON public.events FOR UPDATE
    USING (auth.uid() = organizer_id);

CREATE POLICY "organizers can delete own events"
    ON public.events FOR DELETE
    USING (auth.uid() = organizer_id);

-- Bookings: users can read/insert own
CREATE POLICY "users can read own bookings"
    ON public.bookings FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "users can insert own bookings"
    ON public.bookings FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Tickets: users can read own
CREATE POLICY "users can read own tickets"
    ON public.tickets FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "users can insert own tickets"
    ON public.tickets FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Payments: users can read own
CREATE POLICY "users can read own payments"
    ON public.payments FOR SELECT
    USING (auth.uid() IN (
        SELECT user_id FROM public.bookings WHERE id = booking_id
    ));

CREATE POLICY "users can insert own payments"
    ON public.payments FOR INSERT
    WITH CHECK (auth.uid() IN (
        SELECT user_id FROM public.bookings WHERE id = booking_id
    ));

CREATE POLICY "users can update own payments"
    ON public.payments FOR UPDATE
    USING (auth.uid() IN (
        SELECT user_id FROM public.bookings WHERE id = booking_id
    ));

-- Notifications: users can read/update own
CREATE POLICY "users can read own notifications"
    ON public.notifications FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "users can update own notifications"
    ON public.notifications FOR UPDATE
    USING (auth.uid() = user_id);

-- ===== Admin helper function (bypasses RLS) =====
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN (SELECT role = 'admin' FROM public.profiles WHERE id = auth.uid());
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ===== Admin RLS: admins can do everything =====
CREATE POLICY "admins can read all profiles"
    ON public.profiles FOR SELECT
    USING (public.is_admin());

CREATE POLICY "admins can insert profiles"
    ON public.profiles FOR INSERT
    WITH CHECK (public.is_admin());

CREATE POLICY "admins can update all profiles"
    ON public.profiles FOR UPDATE
    USING (public.is_admin());

CREATE POLICY "admins can delete profiles"
    ON public.profiles FOR DELETE
    USING (public.is_admin());

CREATE POLICY "admins can read all events"
    ON public.events FOR SELECT
    USING (public.is_admin());

CREATE POLICY "admins can insert events"
    ON public.events FOR INSERT
    WITH CHECK (public.is_admin());

CREATE POLICY "admins can update all events"
    ON public.events FOR UPDATE
    USING (public.is_admin());

CREATE POLICY "admins can delete events"
    ON public.events FOR DELETE
    USING (public.is_admin());

CREATE POLICY "admins can read all bookings"
    ON public.bookings FOR SELECT
    USING (public.is_admin());

CREATE POLICY "admins can update bookings"
    ON public.bookings FOR UPDATE
    USING (public.is_admin());

CREATE POLICY "admins can delete bookings"
    ON public.bookings FOR DELETE
    USING (public.is_admin());

CREATE POLICY "admins can read all tickets"
    ON public.tickets FOR SELECT
    USING (public.is_admin());

CREATE POLICY "admins can update tickets"
    ON public.tickets FOR UPDATE
    USING (public.is_admin());

CREATE POLICY "admins can delete tickets"
    ON public.tickets FOR DELETE
    USING (public.is_admin());

CREATE POLICY "admins can read all payments"
    ON public.payments FOR SELECT
    USING (public.is_admin());

CREATE POLICY "admins can insert payments"
    ON public.payments FOR INSERT
    WITH CHECK (public.is_admin());

CREATE POLICY "admins can update payments"
    ON public.payments FOR UPDATE
    USING (public.is_admin());

CREATE POLICY "admins can read all notifications"
    ON public.notifications FOR SELECT
    USING (public.is_admin());

-- ===== Favorites RLS =====
CREATE POLICY "users can manage own favorites"
    ON public.favorites FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "admins can manage all favorites"
    ON public.favorites FOR ALL
    USING (public.is_admin());

-- ===== Organizer RLS: organizers can view bookings for their events =====
CREATE POLICY "organizers can read bookings for own events"
    ON public.bookings FOR SELECT
    USING (auth.uid() IN (
        SELECT organizer_id FROM public.events WHERE id = event_id
    ));

-- ===== Ticket validation: anyone can look up tickets by qr_code =====
CREATE POLICY "anyone can read tickets by qr_code"
    ON public.tickets FOR SELECT
    USING (true);

-- ===== Admin can insert bookings for users =====
CREATE POLICY "admins can insert bookings"
    ON public.bookings FOR INSERT
    WITH CHECK (public.is_admin());
