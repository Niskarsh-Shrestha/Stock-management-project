<?php
error_reporting(0);
ini_set('display_errors', 0);

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
require_once __DIR__ . '/db.php';

if (session_status() !== PHP_SESSION_ACTIVE) {
  session_start();
}

include 'auth_check.php';

if ($user_role !== 'admin' && $user_role !== 'manager') {
    echo json_encode(['success' => false, 'message' => 'Unauthorized']);
    exit;
}

$name = $_POST['categoryName'];

$query = "INSERT INTO categories (CategoryName, dateAdded) VALUES (?, NOW())";
$stmt = $conn->prepare($query);
$stmt->bind_param("s", $name);

if ($stmt->execute()) {
    echo "Category added successfully";
} else {
    echo "Failed to add category";
}

