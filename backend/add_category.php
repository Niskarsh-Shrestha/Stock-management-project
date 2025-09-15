<?php
error_reporting(0);
ini_set('display_errors', 0);

$origin = $_SERVER['HTTP_ORIGIN'] ?? '';
$allowed_origins = [
    'https://stock-management-project.vercel.app',
    'http://localhost:59859' // <-- Your current local Flutter port
];
if (in_array($origin, $allowed_origins, true)) {
    header("Access-Control-Allow-Origin: $origin");
}
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') exit;

header("Content-Type: application/json");
require_once __DIR__ . '/db.php';
require_once __DIR__ . '/auth_check.php';

if (!in_array($user_role, ['admin','manager'], true)) {
  echo json_encode(['success'=>false,'message'=>'Unauthorized']); exit;
}

$raw  = file_get_contents('php://input');
$data = json_decode($raw, true);
if (!is_array($data)) $data = $_POST;

$categoryName = trim($data['categoryName'] ?? '');
if ($categoryName === '') {
  echo json_encode(['success'=>false,'message'=>'Validation failed']); exit;
}

$sql = "INSERT INTO categories (categoryName) VALUES (?)";
$stmt = $conn->prepare($sql);
if (!$stmt) { echo json_encode(['success'=>false,'message'=>$conn->error]); exit; }

$stmt->bind_param('s', $categoryName);

if (!$stmt->execute()) { echo json_encode(['success'=>false,'message'=>$stmt->error]); exit; }
echo json_encode(['success'=>true, 'id'=>$stmt->insert_id]);

