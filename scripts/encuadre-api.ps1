[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)][ValidateSet('GET', 'POST', 'PATCH', 'DELETE')][string]$Method,
  [Parameter(Mandatory = $true)][string]$Path,
  [string]$BodyJson,
  [string]$ApiToken,
  [string]$ApiSession,
  [string]$AuthorizationGrant
)

$baseUrl = 'https://prod.encuadre.muxp.art/api'
$endpoint = "$baseUrl/$($Path.TrimStart('/'))"

if (-not $ApiToken -and -not $ApiSession) {
  $ApiToken = $env:ENCUADRE_PRODUCTION_API_TOKEN
}

if (-not $ApiToken -and -not $ApiSession) {
  try {
    # Solo funciona en un entorno local autorizado que ya tenga acceso a Firebase.
    $ApiToken = (& npx -y firebase-tools@latest functions:secrets:access PRODUCTION_API_TOKEN --project encuadre-prod 2>$null | Select-Object -Last 1).Trim()
  } catch {
    throw 'No se encontró una credencial. Define ENCUADRE_PRODUCTION_API_TOKEN de forma segura, proporciona -ApiToken o inicia una sesión temporal con Clerk.'
  }
}

if (-not $ApiToken -and -not $ApiSession) {
  throw 'No se encontró una credencial. Define ENCUADRE_PRODUCTION_API_TOKEN de forma segura, proporciona -ApiToken o inicia una sesión temporal con Clerk.'
}

$headers = @{ Accept = 'application/json' }
if ($ApiSession) { $headers['X-Encuadre-Session'] = $ApiSession }
else { $headers['X-API-Key'] = $ApiToken }
if ($AuthorizationGrant) { $headers['X-Authorization-Grant'] = $AuthorizationGrant }

$request = @{ Uri = $endpoint; Method = $Method; Headers = $headers; ErrorAction = 'Stop' }
if ($PSBoundParameters.ContainsKey('BodyJson')) {
  $request['ContentType'] = 'application/json'
  $request['Body'] = $BodyJson
}

Invoke-RestMethod @request
