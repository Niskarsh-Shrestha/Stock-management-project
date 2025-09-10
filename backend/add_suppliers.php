<?php
error_reporting(0);
ini_set('display_errors', 0);

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
require_once __DIR__ . '/db.php';
require_once __DIR__ . '/auth_check.php';

if (!in_array($user_role, ['admin','manager'], true)) {
  echo json_encode(['success'=>false,'message'=>'Unauthorized']); exit;
}

$raw  = file_get_contents('php://input');
$data = json_decode($raw, true);
if (!is_array($data)) $data = $_POST;

$supplierName = trim($data['supplierName'] ?? '');
if ($supplierName === '') {
  echo json_encode(['success'=>false,'message'=>'Validation failed']); exit;
}

$sql = "INSERT INTO suppliers (supplierName) VALUES (?)";
$stmt = $conn->prepare($sql);
if (!$stmt) { echo json_encode(['success'=>false,'message'=>$conn->error]); exit; }

$stmt->bind_param('s', $supplierName);

if (!$stmt->execute()) { echo json_encode(['success'=>false,'message'=>$stmt->error]); exit; }
echo json_encode(['success'=>true, 'id'=>$stmt->insert_id]);

