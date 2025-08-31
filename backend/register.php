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

// Sanitize and assign input
$username = trim($data->username ?? '');
$email = trim($data->email ?? '');
$role = trim($data->role ?? ''); // Make sure this is set
$password = $data->password ?? '';

// Basic validation
if (empty($username) || empty($email) || empty($role) || empty($password)) {
    echo json_encode(["success" => false, "message" => "All fields are required."]);
    exit;
}

// Check if user already exists by email
$check = $conn->prepare("SELECT id FROM users WHERE email = ?");
$check->bind_param("s", $email);
$check->execute();
$check->store_result();

if ($check->num_rows > 0) {
    echo json_encode(["success" => false, "message" => "Email already exists."]);
    exit;
}

// Hash password
$hashedPassword = password_hash($password, PASSWORD_BCRYPT);
$regCode = rand(1000, 9999);

// Insert user
$sql = "INSERT INTO users (username, email, role, password, registration_code, is_verified) VALUES (?, ?, ?, ?, ?, 0)";
$stmt = $conn->prepare($sql);
$stmt->bind_param("sssss", $username, $email, $role, $hashedPassword, $regCode);

if ($stmt->execute()) {
    // Send registration code to email
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
        $mail->Body    = "Your registration verification code is: <b>$regCode</b>";

        $mail->send();
        echo json_encode([
            "success" => true,
            "message" => "Account created. Please check your email for the verification code.",
            "email" => $email
        ]);
    } catch (Exception $e) {
        echo json_encode(["success" => false, "message" => "Failed to send verification email."]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Registration failed."]);
}

// Example check:
if ($role == 'data analyst') {
    // Data analyst logic
}
?>
