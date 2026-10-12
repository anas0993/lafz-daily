allprojects {
    repositories {
        // Local mirror first: artifacts pre-fetched (egress proxy is
        // unreliable for Gradle downloads). Falls through to remote repos
        // for anything not mirrored.
        maven { url = uri("file:///home/hatch/sdks/local-maven") }
        google()
        mavenCentral()
    }
    configurations.all {
        resolutionStrategy {
            // shared_preferences_android transitively pulls the ancient
            // activity-ktx:1.5.1, whose classes duplicate androidx.activity:1.8.x.
            // Align it with the modern activity release.
            force("androidx.activity:activity-ktx:1.8.1")
        }
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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
