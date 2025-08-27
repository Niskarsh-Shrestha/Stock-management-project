<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
include 'db.php';

$categoryName = $_GET['categoryId'] ?? ''; // This is actually the category name!
$products = [];

if ($categoryName !== '') {
    $stmt = $conn->prepare("SELECT * FROM products WHERE category = ?");
    if (!$stmt) {
        echo json_encode(['error' => $conn->error]);
        exit;
    }
    $stmt->bind_param("s", $categoryName);
    $stmt->execute();
    $result = $stmt->get_result();
    if (!$result) {
        echo json_encode(['error' => $stmt->error]);
        exit;
    }
    while ($row = $result->fetch_assoc()) {
        $products[] = $row;
    }
    $stmt->close();
}

echo json_encode(['products' => $products]);
$conn->close();
?>

