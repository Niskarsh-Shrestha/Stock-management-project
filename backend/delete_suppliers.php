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

$id = (int)($data['id'] ?? 0);
if ($id <= 0) { echo json_encode(['success'=>false,'message'=>'Invalid id']); exit; }

$stmt = $conn->prepare("DELETE FROM suppliers WHERE id=?");
if (!$stmt) { echo json_encode(['success'=>false,'message'=>$conn->error]); exit; }

$stmt->bind_param('i', $id);
if (!$stmt->execute()) { echo json_encode(['success'=>false,'message'=>$stmt->error]); exit; }
echo json_encode(['success'=>true]);

