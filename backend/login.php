<?php
header("Content-Type: application/json");
include 'db.php';

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

require 'PHPMailer/src/Exception.php';
require 'PHPMailer/src/PHPMailer.php';
require 'PHPMailer/src/SMTP.php';

$data = json_decode(file_get_contents("php://input"));
$input = '';
if (!empty($data->email)) {
    $input = $data->email;
} else if (!empty($data->username)) {
    $input = $data->username;
}
$password = $data->password ?? '';

if ($input === '' || $password === '') {
    echo json_encode(['success' => false, 'message' => 'Email/Username and password required']);
    exit;
}

// Allow login with email OR username
$stmt = $conn->prepare("SELECT * FROM users WHERE (email = ? OR username = ?)");
$stmt->bind_param("ss", $input, $input);
$stmt->execute();
$result = $stmt->get_result();

if ($row = $result->fetch_assoc()) {
    if ($row['is_verified'] != 1) {
        echo json_encode(['success' => false, 'message' => 'Account not approved by admin.']);
        exit;
    }
    if (password_verify($password, $row['password'])) {
        // Generate 4-digit login code
        $login_code = str_pad(rand(0, 9999), 4, '0', STR_PAD_LEFT);

        // Save code in DB (optional, for verification)
        $update = $conn->prepare("UPDATE users SET login_code = ? WHERE id = ?");
        $update->bind_param("si", $login_code, $row['id']);
        $update->execute();

        // Send code via email
        $mail = new PHPMailer(true);
        try {
            $mail->isSMTP();
            $mail->Host = 'smtp.gmail.com';
            $mail->SMTPAuth = true;
            $mail->Username = 'niskarshshrestha@gmail.com'; // <-- your Gmail
            $mail->Password = 'oyup fvjn otmw ctep';    // <-- your Gmail app password
            $mail->SMTPSecure = 'tls';
            $mail->Port = 587;

            $mail->setFrom('niskarshshrestha@gmail.com', 'Admin');
            $mail->addAddress($row['email']); // <-- Always use the user's email

            $mail->Subject = 'Your Admin Login Code';
            $mail->Body    = "Your 4-digit login code is: $login_code";

            $mail->send();
            $mailStatus = "Mail sent";
        } catch (Exception $e) {
            $mailStatus = "Mail error: " . $mail->ErrorInfo;
        }

        echo json_encode([
            'success' => true,
            'require_2fa' => true, // <-- Add this line
            'email' => $row['email'],
            'message' => 'Login code sent to your email.',
            'mail_status' => $mailStatus
        ]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Incorrect password']);
    }
} else {
    echo json_encode(['success' => false, 'message' => 'Account not found']);
}
?>