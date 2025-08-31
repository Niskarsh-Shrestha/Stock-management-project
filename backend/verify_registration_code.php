<?php
header("Content-Type: application/json");
include 'db.php';

$data = json_decode(file_get_contents("php://input"));
$email = trim($data->email ?? '');
$code = trim($data->code ?? '');

if (empty($email) || empty($code)) {
    echo json_encode(["success" => false, "message" => "Email and code are required."]);
    exit;
}

$sql = "SELECT registration_code FROM users WHERE email = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 1) {
    $row = $result->fetch_assoc();
    if ($row['registration_code'] === $code) {
        // Mark user as verified
        $update = $conn->prepare("UPDATE users SET is_verified = 1, registration_code = NULL WHERE email = ?");
        $update->bind_param("s", $email);
        $update->execute();
        echo json_encode(["success" => true, "message" => "Registration verified."]);
    } else {
        echo json_encode(["success" => false, "message" => "Incorrect code."]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Email not found."]);
}
?>