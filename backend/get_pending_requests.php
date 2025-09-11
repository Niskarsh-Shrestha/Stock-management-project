<?php
require_once __DIR__.'/cors.php';
require_once __DIR__.'/db.php';
header('Content-Type: application/json');
header('Cache-Control: no-store');

try {
  $sql = "
    SELECT id, username, email, role
    FROM users
    WHERE is_verified = 1 AND is_approved = 0
    ORDER BY id DESC
  ";
  $res = $conn->query($sql);
  if (!$res) throw new Exception($conn->error);

  $rows = [];
  while ($r = $res->fetch_assoc()) $rows[] = $r;

  echo json_encode(['success'=>true, 'pending'=>$rows, 'count'=>count($rows)]);
} catch (Throwable $e) {
  http_response_code(500);
  echo json_encode(['success'=>false,'error'=>$e->getMessage()]);
}
?>