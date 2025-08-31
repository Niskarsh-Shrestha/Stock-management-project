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
$email = trim($data->email ?? '');

if (empty($email)) {
    echo json_encode(["success" => false, "message" => "Email is required."]);
    exit;
}

// Check if user exists
$sql = "SELECT id FROM users WHERE email = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 1) {
    $code = rand(1000, 9999);
    // Update code in DB
    $update = $conn->prepare("UPDATE users SET registration_code = ? WHERE email = ?");
    $update->bind_param("ss", $code, $email);
    $update->execute();

    // Send code to email
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
        $mail->addAddress($email);

        $mail->isHTML(true);
        $mail->Subject = 'Your Registration Verification Code';
        $mail->Body    = "Your new registration verification code is: <b>$code</b>";

        $mail->send();
        echo json_encode([
            "success" => true,
            "message" => "A new verification code has been sent to your email."
        ]);
    } catch (Exception $e) {
        echo json_encode(["success" => false, "message" => "Failed to resend verification email."]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Email not found."]);
}
?>