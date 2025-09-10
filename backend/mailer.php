<?php
function send_email_api($toEmail, $subject, $htmlBody) {
  $provider  = getenv('EMAIL_PROVIDER') ?: 'brevo';
  $fromEmail = getenv('SMTP_FROM_EMAIL') ?: 'no-reply@example.com';
  $fromName  = getenv('SMTP_FROM_NAME')  ?: 'Stock System';

  if ($provider === 'brevo') {
    $apiKey = getenv('BREVO_API_KEY');
    if (!$apiKey) return "error: missing BREVO_API_KEY";

    $payload = [
      "sender"     => ["email" => $fromEmail, "name" => $fromName],
      "to"         => [["email" => $toEmail]],
      "subject"    => $subject,
      "htmlContent"=> $htmlBody
    ];

    $ch = curl_init("https://api.brevo.com/v3/smtp/email");
    curl_setopt_array($ch, [
      CURLOPT_POST           => true,
      CURLOPT_HTTPHEADER     => ["Content-Type: application/json", "api-key: {$apiKey}"],
      CURLOPT_POSTFIELDS     => json_encode($payload),
      CURLOPT_RETURNTRANSFER => true,
      CURLOPT_TIMEOUT        => 20
    ]);
    $resp = curl_exec($ch);
    $http = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $err  = curl_error($ch);
    curl_close($ch);

    if ($err) return "error: curl: {$err}";
    if ($http >= 200 && $http < 300) return "sent";
    return "error: brevo http {$http} resp {$resp}";
  }

  return "error: unsupported EMAIL_PROVIDER";
}
