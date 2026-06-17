// 👇 أضف هذه الكتلة في أول الملف تماماً فوق كل شيء مسبقاً
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // حزمة المساعدة الخاصة بـ Google Services لربط الـ Firebase
        classpath("com.google.gms:google-services:4.4.2")
    }
}

// الأكواد القديمة الخاصة بك تبقى كما هي تماماً تحتها 👇
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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}