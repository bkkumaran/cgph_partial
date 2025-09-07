public with sharing class EmailGateController {
    // --- Config ---
    private static final Integer OTP_LENGTH      = 6;
    private static final Integer TOKEN_TTL_MIN   = 30; // minutes after verification
    private static final Integer OTP_TTL_MIN     = 10; // minutes to enter OTP
    private static final String  STATUS_PENDING  = 'Pending';
    private static final String  STATUS_VERIFIED = 'Verified';

    // --- Public API ---

    @AuraEnabled(cacheable=false)
    public static String requestOtp(String email) {
        validateEmail(email);
        assertApproved(email); // Enforce allowlist BEFORE issuing OTP

        String otp   = generateOtp(OTP_LENGTH);
        String token = generateToken();

        Verification_Session__c sess = new Verification_Session__c(
            Email__c     = email,
            Otp__c       = otp,
            Token__c     = token,
            Status__c    = STATUS_PENDING,
            Expires_At__c= System.now().addMinutes(OTP_TTL_MIN)
        );
        insert sess;

        sendOtpEmail(email, otp);
        return token; // client stores in sessionStorage
    }

    @AuraEnabled(cacheable=false)
    public static Boolean verifyOtp(String token, String otp) {
        Verification_Session__c sess = [
            SELECT Id, Status__c, Expires_At__c, Otp__c
            FROM Verification_Session__c
            WHERE Token__c = :token
            LIMIT 1
        ];

        if (sess.Status__c == STATUS_VERIFIED) return true;
        if (sess.Expires_At__c <= System.now()) return false;
        if (String.isBlank(otp) || otp != sess.Otp__c) return false;

        // Mark verified and extend token life
        sess.Status__c     = STATUS_VERIFIED;
        sess.Expires_At__c = System.now().addMinutes(TOKEN_TTL_MIN);
        update sess;
        return true;
    }

    @AuraEnabled(cacheable=true)
    public static Boolean isVerified(String token) {
        Verification_Session__c sess = [
            SELECT Status__c, Expires_At__c
            FROM Verification_Session__c
            WHERE Token__c = :token
            LIMIT 1
        ];
        return (sess.Status__c == STATUS_VERIFIED && sess.Expires_At__c > System.now());
    }

    // Example gated data endpoint - outreach tracker should be queried or passed down to LWC here.
    @AuraEnabled(cacheable=false)
    public static List<Account> getGatedData(String token) {
        if (!isVerified(token)) {
            throw new AuraHandledException('Not authorized');
        }
        return [SELECT Id, Name FROM Account LIMIT 20];
    }

    // --- Use Approved_Email__c object to check for allowlisting ---

    private static void assertApproved(String rawEmail) {
        String email = normalizeEmail(rawEmail);
        if (!isApprovedEmail(email)) {
            // Keep generic; do not reveal allowlist contents.
            throw new AuraHandledException('This email is not authorized for access.');
        }
    }

    private static Boolean isApprovedEmail(String email) {
        if (String.isBlank(email)) return false;
        // Approved_Email__c has Email_Normalized__c (Text, unique, case-insensitive) and Active__c (Checkbox)
        List<Approved_Email__c> rows = [
            SELECT Id
            FROM Approved_Email__c
            WHERE Active__c = true
              AND Email_Normalized__c = :email
            LIMIT 1
        ];
        return !rows.isEmpty();
    }

    // Normalize email by trimming whitespace and converting to lowercase for database consistency
    private static String normalizeEmail(String e) {
        return String.isBlank(e) ? null : e.trim().toLowerCase();
    }

    // --- General helpers ---

    private static void validateEmail(String email) {
        // Case-insensitive RFC-lite pattern
        if (String.isBlank(email) ||
            !Pattern.matches('(?i)^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$', email)) {
            throw new AuraHandledException('Please enter a valid email address.');
        }
    }

    // Always return a zero-padded 6-digit code
    private static String generateOtp(Integer len) {
        Integer n = Math.abs(Crypto.getRandomInteger()) / 1000000;
        String s = String.valueOf(n);
        return s.leftPad(len, '0');
    }

    private static String generateToken() {
        // Opaque random token; hex-encoded
        Blob b = Crypto.generateAesKey(256);
        return EncodingUtil.convertToHex(b);
    }

    private static void sendOtpEmail(String email, String otp) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] { email });
        mail.setSubject('Your verification code');
        mail.setPlainTextBody('Your verification code is: ' + otp +
            ' (valid for ' + OTP_TTL_MIN + ' minutes).');
        // Optionally set org-wide email: mail.setOrgWideEmailAddressId('...'); 
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}