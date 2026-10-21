import java.security.KeyStore
import java.security.PrivateKey
import java.security.Signature
import java.security.cert.X509Certificate
import javax.naming.ldap.LdapName

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// Identidade institucional pendente: o fallback serve somente para desenvolvimento.
val releaseApplicationId = providers.gradleProperty("sigadApplicationId")
    .orElse(providers.environmentVariable("SIGAD_ANDROID_APPLICATION_ID"))
    .orNull?.trim()?.takeIf { it.isNotEmpty() }
val releaseStorePath = providers.environmentVariable("SIGAD_ANDROID_KEYSTORE_PATH").orNull
val releaseStorePassword = providers.environmentVariable("SIGAD_ANDROID_KEYSTORE_PASSWORD").orNull
val releaseKeyAlias = providers.environmentVariable("SIGAD_ANDROID_KEY_ALIAS").orNull
val releaseKeyPassword = providers.environmentVariable("SIGAD_ANDROID_KEY_PASSWORD").orNull

val validateReleaseConfiguration = tasks.register("validateReleaseConfiguration") {
    group = "verification"
    description = "Valida identidade e configuração de assinatura sem expor credenciais."
    doLast {
        check(releaseApplicationId != null &&
            releaseApplicationId.matches(Regex("[A-Za-z][A-Za-z0-9_]*(\\.[A-Za-z][A-Za-z0-9_]*)+")) &&
            releaseApplicationId != "com.example" &&
            !releaseApplicationId.startsWith("com.example.")) {
            "Release bloqueado: defina o applicationId institucional aprovado em SIGAD_ANDROID_APPLICATION_ID ou -PsigadApplicationId."
        }
        check(listOf(releaseStorePath, releaseStorePassword, releaseKeyAlias, releaseKeyPassword)
            .all { !it.isNullOrBlank() }) {
            "Release bloqueado: configure SIGAD_ANDROID_KEYSTORE_PATH, SIGAD_ANDROID_KEYSTORE_PASSWORD, SIGAD_ANDROID_KEY_ALIAS e SIGAD_ANDROID_KEY_PASSWORD."
        }
        check(file(releaseStorePath!!).isFile) {
            "Release bloqueado: o arquivo de keystore configurado não existe."
        }
        check(!releaseKeyAlias.equals("androiddebugkey", ignoreCase = true) &&
            file(releaseStorePath).canonicalFile != file("${System.getProperty("user.home")}/.android/debug.keystore").canonicalFile) {
            "Release bloqueado: a chave de depuração não pode assinar a distribuição."
        }
        // Não expor mensagens internas da biblioteca de criptografia.
        val certificate = try {
            val keyStore = KeyStore.getInstance(file(releaseStorePath), releaseStorePassword!!.toCharArray())
            val alias = releaseKeyAlias!!
            val privateKey = keyStore.getKey(alias, releaseKeyPassword!!.toCharArray()) as? PrivateKey
                ?: error("Missing private key")
            val cert = keyStore.getCertificate(alias) as? X509Certificate
                ?: error("Missing certificate")
            val algorithm = when (privateKey.algorithm.uppercase()) {
                "RSA" -> "SHA256withRSA"
                "EC" -> "SHA256withECDSA"
                "DSA" -> "SHA256withDSA"
                "ED25519" -> "Ed25519"
                "ED448" -> "Ed448"
                else -> error("Unsupported key algorithm")
            }
            val challenge = "SIGAD release signing key validation".toByteArray(Charsets.UTF_8)
            val signer = Signature.getInstance(algorithm)
            signer.initSign(privateKey)
            signer.update(challenge)
            val signature = signer.sign()
            val verifier = Signature.getInstance(algorithm)
            verifier.initVerify(cert.publicKey)
            verifier.update(challenge)
            check(verifier.verify(signature))
            cert
        } catch (_: Exception) {
            throw GradleException("Release bloqueado: não foi possível validar keystore, senhas, alias e correspondência da chave privada ao certificado. Confira a configuração de assinatura institucional.")
        }
        val isAndroidDebugCertificate = LdapName(certificate.subjectX500Principal.name).rdns.any {
            it.type.equals("CN", ignoreCase = true) &&
                it.value.toString().equals("Android Debug", ignoreCase = true)
        }
        check(!isAndroidDebugCertificate) {
            "Release bloqueado: certificado Android Debug não pode assinar a distribuição."
        }
    }
}

tasks.configureEach {
    if (name == "preReleaseBuild" || name == "validateSigningRelease") {
        dependsOn(validateReleaseConfiguration)
    }
}

android {
    namespace = "com.example.sigad"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }
    defaultConfig {
        applicationId = releaseApplicationId ?: "com.example.sigad"
        // AppAuth 12 exige Android API >= 24.
        minSdk = 24
        // Deve corresponder a SIGAD_OIDC_REDIRECT_URI e à configuração no IdP.
        manifestPlaceholders.putAll(mapOf("appAuthRedirectScheme" to "sigad-auth"))
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
    signingConfigs {
        create("institutionalRelease") {
            storeFile = releaseStorePath?.takeIf { it.isNotBlank() }?.let { file(it) }
            storePassword = releaseStorePassword
            keyAlias = releaseKeyAlias
            keyPassword = releaseKeyPassword
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("institutionalRelease")
        }
    }
}

flutter {
    source = "../.."
}
