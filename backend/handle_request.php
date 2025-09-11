<?php
header("Content-Type: application/json");
require_once __DIR__ . '/db.php';

$data = json_decode(file_get_contents("php://input"), true) ?: [];
$user_id = $data['user_id'] ?? $_POST['user_id'] ?? $_GET['user_id'] ?? null;
$approve = $data['approve'] ?? $_POST['approve'] ?? false;

if (!$user_id) {
    echo json_encode(['success' => false, 'message' => 'User ID required']);
    exit;
}

$stmt = $conn->prepare("SELECT email FROM users WHERE id = ?");
$stmt->bind_param("i", $user_id);
$stmt->execute();
$res = $stmt->get_result();
$user = $res->fetch_assoc();
$email = $user['email'] ?? '';

if ($approve) {
    $stmt = $conn->prepare("UPDATE users SET is_approved = 1 WHERE id = ?");
    $stmt->bind_param("i", $user_id);
    $stmt->execute();
    $subject = "Account Approved";
    $message = "Your account has been approved. You can now login.";

    // Send email using Resend API
    $api_key = 're_JBudTybx_3Yb7wmdpzCcJE13eqBYVLAf2';
    $email_data = [
        "from" => "no-reply@mail.stockmgmt.app",
        "to" => $email,
        "subject" => $subject,
        "html" => "<p>$message</p>"
    ];

    $ch = curl_init("https://api.resend.com/emails");
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        "Authorization: Bearer $api_key",
        "Content-Type: application/json"
    ]);
    curl_setopt($ch, CURLOPT_POST, 1);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($email_data));
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

    $response = curl_exec($ch);
    $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    $mailStatus = ($http_code === 200 || $http_code === 202) ? 'Mail sent' : 'Mail error: ' . $response;

    echo json_encode([
        'success' => true,
        'message' => 'User approved and notified.',
        'mail_status' => $mailStatus
    ]);
} else {
    // ...handle rejection if needed...
}
?>