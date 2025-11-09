// Top-level Gradle build file for the Flutter project

plugins {
    // ✅ Let Flutter handle AGP version automatically
    id("com.android.application") apply false
    id("com.android.library") apply false
    id("org.jetbrains.kotlin.android") apply false
    id("com.google.gms.google-services") apply false // Firebase plugin
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ✅ Redirect build output to root project build folder
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

// ✅ Ensure each subproject outputs correctly
subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")
}

// ✅ Define clean task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
