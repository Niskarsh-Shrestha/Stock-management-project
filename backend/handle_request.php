<?php
header("Content-Type: application/json");
require_once __DIR__ . '/db.php';

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

require 'PHPMailer/src/Exception.php';
require 'PHPMailer/src/PHPMailer.php';
require 'PHPMailer/src/SMTP.php';

if (session_status() !== PHP_SESSION_ACTIVE) {
  session_start();
}

$data = json_decode(file_get_contents("php://input"));
$id = $data->id ?? 0;
$approve = $data->approve ?? false;
$email = $data->email ?? '';

if ($id == 0 || empty($email)) {
    echo json_encode(['success' => false, 'message' => 'Invalid request']);
    exit;
}

if ($approve) {
    $stmt = $conn->prepare("UPDATE users SET is_verified = 1 WHERE id = ?");
    $stmt->bind_param("i", $id);
    $stmt->execute();
    $subject = "Account Approved";
    $message = "Your account has been approved. You can now login.";
} else {
    $stmt = $conn->prepare("DELETE FROM users WHERE id = ?");
    $stmt->bind_param("i", $id);
    $stmt->execute();
    $subject = "Account Rejected";
    $message = "Your account request has been rejected by the admin.";
}

// Send email using PHPMailer
$mail = new PHPMailer(true);
$mailStatus = "Mail sent";
try {
    $mail->isSMTP();
    $mail->Host = 'smtp.gmail.com';
    $mail->SMTPAuth = true;
    $mail->Username = 'niskarshshrestha@gmail.com'; // <-- your Gmail address
    $mail->Password = 'oyup fvjn otmw ctep';    // <-- your Gmail app password
    $mail->SMTPSecure = 'tls';
    $mail->Port = 587;

    $mail->setFrom('niskarshshrestha@gmail.com', 'Admin');
    $mail->addAddress($email);

    $mail->Subject = $subject;
    $mail->Body    = $message;

    $mail->send();
} catch (Exception $e) {
    $mailStatus = "Mail error: " . $mail->ErrorInfo;
}

echo json_encode([
    'success' => true,
    'message' => $approve ? 'User approved and notified.' : 'User rejected and notified.',
    'mail_status' => $mailStatus
]);
?>