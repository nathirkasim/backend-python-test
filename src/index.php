<?php
declare(strict_types=1);

/**
 * Minimal PHP Test Application Entry Point
 *
 * PURPOSE:
 * A benign, safe HTTP entry point designed solely to make the repository
 * recognizable to PHP-aware static analysis (SAST), Software Composition
 * Analysis (SCA), and runtime vulnerability inspection tools.
 *
 * SAFETY GUARANTEES:
 * - No shell execution or process spawning (e.g. system, exec, shell_exec, passthru, proc_open).
 * - No command injection vectors or eval/unserialize constructs.
 * - No malicious request handling or heap-grooming payloads.
 * - No memory exhaustion or infinite recursion logic.
 * - No proof-of-concept exploit code.
 * - No hardcoded secrets, credentials, or production tokens.
 */

header('Content-Type: application/json; charset=utf-8');

$statusData = [
    'application' => 'php2shell-security-test',
    'status' => 'healthy',
    'timestamp' => gmdate('Y-m-d\TH:i:s\Z'),
    'runtime' => [
        'php_version' => PHP_VERSION,
        'php_sapi' => PHP_SAPI,
        'zend_version' => zend_version(),
    ],
    'target_advisories' => [
        'CVE-2026-109618',
        'CVE-2026-109619'
    ],
    'purpose' => 'Defensive validation of security scanner detection capabilities'
];

echo json_encode($statusData, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES) . PHP_EOL;
