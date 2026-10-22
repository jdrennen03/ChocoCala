import com.android.apksig.ApkSigner;
import com.android.apksig.ApkVerifier;

import java.io.File;
import java.io.FileInputStream;
import java.security.KeyStore;
import java.security.PrivateKey;
import java.security.cert.X509Certificate;
import java.util.Collections;

/**
 * Signs an APK with v1, v2 and v3 signatures (apksig) and verifies the result.
 *
 * Usage: java SignApk <in.apk> <out.apk> <keystore.p12> <storePassword> <alias>
 */
public class SignApk {
    public static void main(String[] args) throws Exception {
        File in = new File(args[0]);
        File out = new File(args[1]);
        char[] pass = args[3].toCharArray();

        KeyStore ks = KeyStore.getInstance("PKCS12");
        try (FileInputStream fis = new FileInputStream(args[2])) {
            ks.load(fis, pass);
        }
        PrivateKey key = (PrivateKey) ks.getKey(args[4], pass);
        X509Certificate cert = (X509Certificate) ks.getCertificate(args[4]);

        ApkSigner.SignerConfig signer = new ApkSigner.SignerConfig.Builder("chococala", key, Collections.singletonList(cert)).build();
        new ApkSigner.Builder(Collections.singletonList(signer))
                .setInputApk(in)
                .setOutputApk(out)
                .setMinSdkVersion(24)
                .setV1SigningEnabled(true)
                .setV2SigningEnabled(true)
                .setV3SigningEnabled(true)
                .build()
                .sign();

        ApkVerifier.Result result = new ApkVerifier.Builder(out).build().verify();
        System.out.println("Signed " + out + " | verified=" + result.isVerified()
                + " v1=" + result.isVerifiedUsingV1Scheme()
                + " v2=" + result.isVerifiedUsingV2Scheme()
                + " v3=" + result.isVerifiedUsingV3Scheme());
        result.getErrors().forEach(e -> System.out.println("ERROR: " + e));
        if (!result.isVerified()) System.exit(1);
    }
}
