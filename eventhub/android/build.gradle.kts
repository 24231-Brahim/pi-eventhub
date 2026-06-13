allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// Some plugins (e.g. file_picker) ship with an older compileSdk than the
// app's. Force all Android library subprojects to compile against the same
// SDK as the app to avoid AAR metadata version mismatches.
subprojects {
    if (project.name != "app") {
        afterEvaluate {
            extensions.findByName("android")?.let { ext ->
                val setCompileSdkVersion = ext.javaClass.getMethod("setCompileSdkVersion", Int::class.javaPrimitiveType)
                setCompileSdkVersion.invoke(ext, 36)
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
