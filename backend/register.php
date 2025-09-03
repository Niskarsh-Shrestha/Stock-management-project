<?php
header("Content-Type: application/json");
include 'db.php';

// Remove PHPMailer namespace imports; use classes directly

$data = json_decode(file_get_contents("php://input"));
$username = trim($data->username ?? '');
$email = trim($data->email ?? '');
$password = $data->password ?? '';
$role = $data->role ?? '';

if ($username === '' || $email === '' || $password === '' || $role === '') {
    echo json_encode(['success' => false, 'message' => 'All fields required']);
    exit;
}

// Hash password
$hashedPassword = password_hash($password, PASSWORD_DEFAULT);

// Role logic
$is_verified = 0;
$approval_message = 'Account request sent. Await admin approval.';
$registration_code = null;

// Check if trying to create manager/employee
if ($role === 'manager' || $role === 'employee') {
    $adminCheck = $conn->query("SELECT id FROM users WHERE role = 'admin' AND is_verified = 1");
    if ($adminCheck->num_rows == 0) {
        echo json_encode(['success' => false, 'message' => 'Cannot create manager/employee until at least one admin exists and is approved.']);
        exit;
    }
}

// Check if trying to create a new admin
if ($role === 'admin') {
    $adminCheck = $conn->query("SELECT id FROM users WHERE role = 'admin' AND is_verified = 1");
    if ($adminCheck->num_rows > 0) {
        // New admin needs approval and verification code
        $is_verified = 0;
        $approval_message = 'Admin account request sent. Await approval from existing admin.';
        // Generate 4-digit code
        $registration_code = str_pad(rand(0, 9999), 4, '0', STR_PAD_LEFT);

        // Send code to email using PHPMailer
        require 'PHPMailer/src/Exception.php';
        require 'PHPMailer/src/PHPMailer.php';
        require 'PHPMailer/src/SMTP.php';

        $mail = new PHPMailer\PHPMailer\PHPMailer(true);
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

            $mail->Subject = "Your Admin Registration Code";
            $mail->Body    = "Your verification code is: $registration_code";

            $mail->send();
        } catch (Exception $e) {
            // Optionally log or handle error
        }
    } else {
        // First admin, auto approve
        $is_verified = 1;
        $approval_message = 'Admin account created and auto-approved.';
        $registration_code = null;
    }
}

// Insert user
$stmt = $conn->prepare("INSERT INTO users (username, email, password, role, is_verified, registration_code) VALUES (?, ?, ?, ?, ?, ?)");
$stmt->bind_param("ssssss", $username, $email, $hashedPassword, $role, $is_verified, $registration_code);
$stmt->execute();

echo json_encode(['success' => true, 'message' => $approval_message]);
?>
