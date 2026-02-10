buildscript {
    repositories {
        google()  // Make sure this is included
        mavenCentral()
    }

    dependencies {
        classpath("com.google.gms:google-services:4.4.1")
        classpath("com.android.tools.build:gradle:8.1.0")
    }
}

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

subprojects {
    val project = this
    if (project.state.executed) {
        applyNamespaceWorkaround(project)
    } else {
        afterEvaluate {
            applyNamespaceWorkaround(project)
        }
    }
}

fun applyNamespaceWorkaround(project: Project) {
    val android = project.extensions.findByName("android") as? com.android.build.gradle.BaseExtension
    if (android != null && android.namespace == null) {
        val manifestFile = project.file("${project.projectDir}/src/main/AndroidManifest.xml")
        if (manifestFile.exists()) {
            val manifestContents = manifestFile.readText()
            val packageMatch = Regex("package=\"([^\"]+)\"").find(manifestContents)
            if (packageMatch != null) {
                android.namespace = packageMatch.groupValues[1]
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
