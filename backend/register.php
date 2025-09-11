<?php
header("Access-Control-Allow-Origin: https://stock-management-project.vercel.app");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}
header("Content-Type: application/json");

// Read JSON payload
$data = json_decode(file_get_contents('php://input'), true);

$username = $data['username'] ?? '';
$email = $data['email'] ?? '';
$password = $data['password'] ?? '';
$role = $data['role'] ?? '';

// Validate fields
if (!$username || !$email || !$password || !$role) {
    echo json_encode(['success' => false, 'message' => 'All fields required']);
    exit;
}

// Hash password
$hashedPassword = password_hash($password, PASSWORD_DEFAULT);

// Always generate a registration code
$registration_code = str_pad(rand(0, 9999), 4, '0', STR_PAD_LEFT);
$is_verified = 0;
$is_approved = 0;

// Send registration code email
require 'phpmailer/src/Exception.php';
require 'phpmailer/src/PHPMailer.php';
require 'phpmailer/src/SMTP.php';

$mail = new PHPMailer\PHPMailer\PHPMailer(true);
try {
    $mail->isSMTP();
    $mail->Host = 'smtp.gmail.com';
    $mail->SMTPAuth = true;
    $mail->Username = 'niskarshshrestha@gmail.com'; // your Gmail address
    $mail->Password = 'oyup fvjn otmw ctep';        // your Gmail app password
    $mail->SMTPSecure = 'tls';
    $mail->Port = 587;

    $mail->setFrom('niskarshshrestha@gmail.com', 'Admin');
    $mail->addAddress($email);

    $mail->Subject = "Your Registration Code";
    $mail->Body    = "Your verification code is: $registration_code";

    $mail->send();
} catch (Exception $e) {
    echo json_encode(['success' => false, 'message' => 'Mail error: ' . $mail->ErrorInfo]);
    exit;
}

// Insert user into database
require 'db.php';
$stmt = $conn->prepare("INSERT INTO users (username, email, password, role, is_verified, registration_code, is_approved) VALUES (?, ?, ?, ?, ?, ?, ?)");
$stmt->bind_param("ssssisi", $username, $email, $hashedPassword, $role, $is_verified, $registration_code, $is_approved);

if ($stmt->execute()) {
    echo json_encode(['success' => true, 'message' => 'Registration successful. Please check your email for the verification code.']);
} else {
    echo json_encode(['success' => false, 'message' => 'Registration failed.']);
}
?>
