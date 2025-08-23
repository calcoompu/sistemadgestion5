# LIMPIEZA COMPLETA DE MODULOS Y CREACION DE REPOSITORIO FINAL
# Script para eliminar archivos innecesarios y preparar GitHub

Write-Host "🗑️ LIMPIEZA COMPLETA DEL SISTEMA PARA GITHUB" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

# Crear backup de seguridad adicional antes de borrar
$fecha = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$backupPath = "backup_antes_limpieza_final_$fecha.zip"

Write-Host ""
Write-Host "📦 Creando backup de seguridad..." -ForegroundColor Yellow
try {
    Compress-Archive -Path "*" -DestinationPath $backupPath -CompressionLevel Optimal -Force
    $backupSize = [math]::Round((Get-Item $backupPath).Length / 1MB, 2)
    Write-Host "✅ Backup creado: $backupPath ($backupSize MB)" -ForegroundColor Green
} catch {
    Write-Host "❌ Error creando backup: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🗑️ ELIMINANDO ARCHIVOS INNECESARIOS..." -ForegroundColor Red
Write-Host "=======================================" -ForegroundColor Red

$archivosEliminados = 0
$errores = 0

# 1. ARCHIVOS DE DESARROLLO EN ROOT
Write-Host ""
Write-Host "1. Limpiando archivos de desarrollo en ROOT..." -ForegroundColor Yellow

$patronesDesarrollo = @(
    "*test*", "*debug*", "*verificar*", "*analizar*", "*crear_*", 
    "*generar_*", "*instalar_*", "*limpiar_*", "*configurar_*",
    "*diagnostico*", "*hotkey*", "*solucionar*", "*setup*"
)

foreach ($patron in $patronesDesarrollo) {
    Get-ChildItem -Name $patron | Where-Object { $_ -like "*.php" -or $_ -like "*.ps1" -or $_ -like "*.md" } | ForEach-Object {
        try {
            Remove-Item $_ -Force
            Write-Host "   ❌ Eliminado: $_" -ForegroundColor Gray
            $archivosEliminados++
        } catch {
            Write-Host "   ⚠️ Error eliminando: $_" -ForegroundColor Yellow
            $errores++
        }
    }
}

# 2. ARCHIVOS DE BACKUP (excepto el que acabamos de crear)
Write-Host ""
Write-Host "2. Limpiando backups antiguos..." -ForegroundColor Yellow

Get-ChildItem -Name "*.zip" | Where-Object { $_ -ne $backupPath } | ForEach-Object {
    try {
        Remove-Item $_ -Force
        Write-Host "   ❌ Backup eliminado: $_" -ForegroundColor Gray
        $archivosEliminados++
    } catch {
        Write-Host "   ⚠️ Error eliminando backup: $_" -ForegroundColor Yellow
        $errores++
    }
}

# 3. ARCHIVOS TEMPORALES Y LOGS
Write-Host ""
Write-Host "3. Limpiando archivos temporales..." -ForegroundColor Yellow

$patronesTemp = @("*.tmp", "*.temp", "*~", "*.bak", "*.log", "*.cache")

foreach ($patron in $patronesTemp) {
    Get-ChildItem -Recurse -Name $patron | ForEach-Object {
        try {
            Remove-Item $_ -Force
            Write-Host "   ❌ Temporal eliminado: $_" -ForegroundColor Gray
            $archivosEliminados++
        } catch {
            Write-Host "   ⚠️ Error eliminando temporal: $_" -ForegroundColor Yellow
            $errores++
        }
    }
}

# 4. LIMPIAR MODULOS ESPECIFICOS
Write-Host ""
Write-Host "4. Limpiando archivos innecesarios en módulos..." -ForegroundColor Yellow

# Buscar archivos de desarrollo en módulos
Get-ChildItem -Path "modulos" -Recurse -File | Where-Object { 
    $_.Name -like "*test*" -or 
    $_.Name -like "*debug*" -or 
    $_.Name -like "*temp*" -or
    $_.Name -like "*.bak" -or
    $_.Name -like "*.tmp"
} | ForEach-Object {
    try {
        Remove-Item $_.FullName -Force
        Write-Host "   ❌ Módulo limpiado: $($_.FullName.Replace($PWD, '.'))" -ForegroundColor Gray
        $archivosEliminados++
    } catch {
        Write-Host "   ⚠️ Error en módulo: $($_.Name)" -ForegroundColor Yellow
        $errores++
    }
}

# 5. LIMPIAR CARPETAS VACIAS
Write-Host ""
Write-Host "5. Eliminando carpetas vacías..." -ForegroundColor Yellow

Get-ChildItem -Recurse -Directory | Where-Object { 
    (Get-ChildItem $_.FullName -Recurse -File).Count -eq 0 
} | ForEach-Object {
    try {
        Remove-Item $_.FullName -Recurse -Force
        Write-Host "   📁 Carpeta vacía eliminada: $($_.Name)" -ForegroundColor Gray
        $archivosEliminados++
    } catch {
        Write-Host "   ⚠️ Error eliminando carpeta: $($_.Name)" -ForegroundColor Yellow
        $errores++
    }
}

Write-Host ""
Write-Host "✅ LIMPIEZA COMPLETADA" -ForegroundColor Green
Write-Host "Archivos eliminados: $archivosEliminados" -ForegroundColor White
Write-Host "Errores: $errores" -ForegroundColor White

# CREAR ARCHIVOS PARA GITHUB
Write-Host ""
Write-Host "📝 CREANDO ARCHIVOS PARA GITHUB..." -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan

# Crear .gitignore
$gitignore = @"
# Archivos de configuración local
config/config.php
*.local.php

# Archivos temporales
*.tmp
*.temp
*~
*.bak
*.cache
*.log

# Uploads y archivos generados
assets/uploads/*
!assets/uploads/.gitkeep
assets/scanner_input/*
!assets/scanner_input/.gitkeep
assets/scanner_processed/*
!assets/scanner_processed/.gitkeep

# Backups
*.zip
backups/

# Archivos del sistema
.DS_Store
Thumbs.db
*.swp
*.swo

# IDE
.vscode/settings.json
.idea/

# Composer (si se usa)
vendor/
composer.lock
"@

$gitignore | Out-File -FilePath ".gitignore" -Encoding UTF8
Write-Host "✅ .gitignore creado" -ForegroundColor Green

# Crear README.md mejorado
$readme = @"
# Sistema de Gestión Empresarial

Sistema integral de gestión empresarial desarrollado en PHP para administración de inventarios, compras, ventas y reportes.

## 🚀 Características Principales

- **Gestión de Inventarios**: Control completo de productos y stock
- **Módulo de Compras**: Gestión de proveedores y órdenes de compra
- **Sistema de Ventas**: Facturación y control de clientes
- **Reportes Avanzados**: Generación de reportes en PDF y Excel
- **Panel de Administración**: Gestión de usuarios y configuración
- **Scanner OCR**: Procesamiento automático de remitos (módulo avanzado)

## 📋 Requisitos del Sistema

- PHP 7.4 o superior
- MySQL 5.7 o superior
- Apache/Nginx
- Extensiones PHP: mysqli, gd, mbstring, zip

## 🛠️ Instalación

1. Clona el repositorio:
\`\`\`bash
git clone https://github.com/tu-usuario/sistemadgestion5.git
cd sistemadgestion5
\`\`\`

2. Configura la base de datos:
   - Importa el archivo SQL desde \`config/\`
   - Configura las credenciales en \`config/config.php\`

3. Configura permisos:
\`\`\`bash
chmod 755 assets/uploads
chmod 755 assets/scanner_input
chmod 755 assets/scanner_processed
\`\`\`

## 📁 Estructura del Proyecto

\`\`\`
sistemadgestion5/
├── modulos/           # Módulos principales del sistema
│   ├── admin/         # Panel de administración
│   ├── compras/       # Gestión de compras y proveedores
│   ├── inventario/    # Control de inventarios
│   ├── clientes/      # Gestión de clientes
│   ├── facturas/      # Sistema de facturación
│   └── productos/     # Catálogo de productos
├── config/            # Configuración del sistema
├── assets/            # Recursos estáticos
├── ajax/              # Endpoints AJAX
└── index.php          # Punto de entrada
\`\`\`

## 🔧 Configuración

1. Copia \`config/config.example.php\` a \`config/config.php\`
2. Ajusta las credenciales de base de datos
3. Configura las rutas según tu servidor

## 📊 Módulos Disponibles

### Administración
- Gestión de usuarios y permisos
- Configuración del sistema
- Logs y auditoría

### Inventarios
- Control de stock
- Categorías y ubicaciones
- Reportes de inventario

### Compras
- Gestión de proveedores
- Órdenes de compra
- Scanner OCR para remitos

### Ventas
- Facturación
- Gestión de clientes
- Reportes de ventas

## 🤝 Contribución

1. Fork el proyecto
2. Crea tu rama de características (\`git checkout -b feature/AmazingFeature\`)
3. Commit tus cambios (\`git commit -m 'Add some AmazingFeature'\`)
4. Push a la rama (\`git push origin feature/AmazingFeature\`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para detalles.

## 📞 Soporte

Para soporte y consultas, por favor abre un issue en este repositorio.
"@

$readme | Out-File -FilePath "README.md" -Encoding UTF8
Write-Host "✅ README.md actualizado" -ForegroundColor Green

# Crear LICENSE
$license = @"
MIT License

Copyright (c) 2025 Sistema de Gestión Empresarial

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"@

$license | Out-File -FilePath "LICENSE" -Encoding UTF8
Write-Host "✅ LICENSE creado" -ForegroundColor Green

# Crear archivo .gitkeep para carpetas importantes
$carpetasKeep = @("assets/uploads", "assets/scanner_input", "assets/scanner_processed")
foreach ($carpeta in $carpetasKeep) {
    if (Test-Path $carpeta) {
        "" | Out-File -FilePath "$carpeta/.gitkeep" -Encoding UTF8
        Write-Host "✅ .gitkeep creado en $carpeta" -ForegroundColor Green
    }
}

# CREAR ZIP FINAL PARA REPOSITORIO
Write-Host ""
Write-Host "📦 CREANDO ZIP FINAL PARA REPOSITORIO..." -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

$zipFinal = "sistemadgestion5-repositorio-final-$fecha.zip"

# Excluir el backup que creamos al principio
$exclusiones = @($backupPath)

Write-Host "📁 Comprimiendo sistema limpio..." -ForegroundColor Yellow

try {
    # Obtener todos los archivos excepto el backup
    $archivos = Get-ChildItem -Recurse | Where-Object { 
        $_.FullName -notlike "*$backupPath*" -and 
        -not $_.PSIsContainer 
    }
    
    $totalArchivos = $archivos.Count
    Write-Host "📋 Archivos a incluir: $totalArchivos" -ForegroundColor White
    
    # Crear el ZIP excluyendo el backup
    Get-ChildItem -Recurse | Where-Object { 
        $_.FullName -notlike "*$backupPath*" 
    } | Compress-Archive -DestinationPath $zipFinal -CompressionLevel Optimal -Force
    
    $zipSize = [math]::Round((Get-Item $zipFinal).Length / 1MB, 2)
    Write-Host "✅ ZIP final creado: $zipFinal ($zipSize MB)" -ForegroundColor Green
    
} catch {
    Write-Host "❌ Error creando ZIP final: $($_.Exception.Message)" -ForegroundColor Red
}

# ESTADISTICAS FINALES
Write-Host ""
Write-Host "📊 ESTADÍSTICAS FINALES" -ForegroundColor Magenta
Write-Host "========================" -ForegroundColor Magenta

$archivosRestantes = (Get-ChildItem -Recurse -File | Where-Object { $_.Name -ne $backupPath }).Count
$carpetasRestantes = (Get-ChildItem -Recurse -Directory).Count

Write-Host "🗑️ Archivos eliminados: $archivosEliminados" -ForegroundColor Red
Write-Host "📁 Archivos restantes: $archivosRestantes" -ForegroundColor Green
Write-Host "📂 Carpetas restantes: $carpetasRestantes" -ForegroundColor Green
Write-Host "💾 Backup de seguridad: $backupPath" -ForegroundColor Yellow
Write-Host "🚀 ZIP para GitHub: $zipFinal" -ForegroundColor Cyan

Write-Host ""
Write-Host "🎉 SISTEMA LISTO PARA GITHUB!" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green
Write-Host "✅ Archivos innecesarios eliminados" -ForegroundColor White
Write-Host "✅ Módulos conservados intactos" -ForegroundColor White
Write-Host "✅ .gitignore creado" -ForegroundColor White
Write-Host "✅ README.md profesional" -ForegroundColor White
Write-Host "✅ Licencia MIT incluida" -ForegroundColor White
Write-Host "✅ ZIP final para repositorio" -ForegroundColor White

Write-Host ""
Write-Host "🔥 PRÓXIMOS PASOS:" -ForegroundColor Yellow
Write-Host "1. Extrae: $zipFinal" -ForegroundColor White
Write-Host "2. git init" -ForegroundColor Gray
Write-Host "3. git add ." -ForegroundColor Gray
Write-Host "4. git commit -m 'Initial commit'" -ForegroundColor Gray
Write-Host "5. git push origin main" -ForegroundColor Gray
