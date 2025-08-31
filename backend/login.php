<?php
header("Content-Type: application/json");
include 'db.php';

// Include PHPMailer classes
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;
require 'phpmailer/src/Exception.php';
require 'phpmailer/src/PHPMailer.php';
require 'phpmailer/src/SMTP.php';

$data = json_decode(file_get_contents("php://input"));
$login_id = trim($data->login_id ?? '');
$role = trim($data->role ?? ''); // Will be 'admin', 'data analyst', 'manager', or 'employee'
$password = $data->password ?? '';

if (empty($login_id) || empty($role) || empty($password)) {
    echo json_encode(["success" => false, "message" => "All fields are required."]);
    exit;
}

// Example query:
$sql = "SELECT * FROM users WHERE (email = ? OR username = ?) AND role = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("sss", $login_id, $login_id, $role);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 1) {
    $user = $result->fetch_assoc();
    if (password_verify($password, $user['password'])) {
        // Generate 4-digit code
        $code = rand(1000, 9999);
        // Store code in DB
        $update = $conn->prepare("UPDATE users SET login_code = ? WHERE email = ?");
        $update->bind_param("ss", $code, $user['email']);
        $update->execute();

        // Send code to email using PHPMailer
        $mail = new PHPMailer(true);
        try {
            $mail->isSMTP();
            $mail->Host       = 'smtp.gmail.com';
            $mail->SMTPAuth   = true;
            $mail->Username   = 'niskarshshrestha@gmail.com'; // Your Gmail address
            $mail->Password   = 'oyup fvjn otmw ctep';   // Your Gmail App Password
            $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
            $mail->Port       = 587;

            $mail->setFrom('niskarshshrestha@gmail.com', 'Stock Management App');
            $mail->addAddress($user['email']);

            $mail->isHTML(true);
            $mail->Subject = 'Your Login Verification Code';
            $mail->Body    = "Your login verification code is: <b>$code</b>";

            $mail->send();
            echo json_encode(["success" => true, "message" => "Verification code sent to your email.", "require_2fa" => true, "email" => $user['email']]);
        } catch (Exception $e) {
            echo json_encode(["success" => false, "message" => "Failed to send email. Mailer Error: {$mail->ErrorInfo}"]);
        }
    } else {
        echo json_encode(["success" => false, "message" => "Incorrect password."]);
    }
} else {
    echo json_encode(["success" => false, "message" => "User not found."]);
}
?>