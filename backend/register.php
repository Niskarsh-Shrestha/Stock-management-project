<?php
header("Content-Type: application/json");
include 'db.php';

$data = json_decode(file_get_contents("php://input"));

// Sanitize and assign input
$username = trim($data->username ?? '');
$email = trim($data->email ?? '');
$role = trim($data->role ?? '');
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

// Insert user
$sql = "INSERT INTO users (username, email, role, password) VALUES (?, ?, ?, ?)";
$stmt = $conn->prepare($sql);
$stmt->bind_param("ssss", $username, $email, $role, $hashedPassword);

if ($stmt->execute()) {
    echo json_encode([
        "success" => true,
        "message" => "Account created.",
        "role" => $role
    ]);
} else {
    echo json_encode(["success" => false, "message" => "Registration failed."]);
}
?>
