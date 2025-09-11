<?php
// verify_registration_code.php
header("Content-Type: application/json");
include 'db.php';

$data = json_decode(file_get_contents("php://input"));
$email = trim($data->email ?? '');
$code = trim($data->code ?? '');

$stmt = $conn->prepare("SELECT registration_code FROM users WHERE email = ?");
$stmt->bind_param("s", $email);
$stmt->execute();
$stmt->bind_result($dbCode);
$stmt->fetch();
$stmt->close();

if ($dbCode === $code) {
    $update = $conn->prepare("UPDATE users SET is_verified = 1, is_verified_email = 1 WHERE email = ?");
    $update->bind_param("s", $email);
    $update->execute();
    echo json_encode(["success" => true, "message" => "Email verified!"]);
} else {
    echo json_encode(["success" => false, "message" => "Incorrect code."]);
}
?>