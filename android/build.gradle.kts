allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.layout.buildDirectory = file("../build")

subprojects {
    // Put each module's build dir inside the shared root build dir
    layout.buildDirectory = file("${rootProject.layout.buildDirectory.get()}/${project.name}")
}

// Standard clean task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}