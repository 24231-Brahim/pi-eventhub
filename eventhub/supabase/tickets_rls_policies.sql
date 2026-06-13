-- =============================================================================
-- Tickets RLS policies for QR validation
-- =============================================================================
-- Run this in the Supabase SQL editor.
--
-- Problem it fixes:
--   When an organizer scans a participant's ticket QR, the validation query
--   (select * from tickets where qr_code = ...) returns 0 rows, even though
--   the ticket exists. This is because Row Level Security only lets a user
--   read their OWN tickets (user_id = auth.uid()). The organizer is not the
--   ticket owner, so RLS hides the row and the scan reports "Ticket not found".
--
-- These policies additionally allow the organizer of an event to SELECT and
-- UPDATE tickets that belong to THEIR events, which is what QR check-in needs.
-- RLS policies are OR-combined, so existing "users see their own tickets"
-- policies keep working for participants.
-- =============================================================================

-- Make sure RLS is enabled (it usually already is).
alter table public.tickets enable row level security;

-- Allow event organizers to READ tickets for events they own.
drop policy if exists "Organizers can read tickets for their events" on public.tickets;
create policy "Organizers can read tickets for their events"
on public.tickets
for select
using (
  exists (
    select 1
    from public.events e
    where e.id = tickets.event_id
      and e.organizer_id = auth.uid()
  )
);

-- Allow event organizers to UPDATE (mark as used) tickets for their events.
drop policy if exists "Organizers can update tickets for their events" on public.tickets;
create policy "Organizers can update tickets for their events"
on public.tickets
for update
using (
  exists (
    select 1
    from public.events e
    where e.id = tickets.event_id
      and e.organizer_id = auth.uid()
  )
)
with check (
  exists (
    select 1
    from public.events e
    where e.id = tickets.event_id
      and e.organizer_id = auth.uid()
  )
);
