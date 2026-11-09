# Taller Integrador: Banco de Sangre (HemoMed)

**Universidad de San Buenaventura Medellín**  
**Programa:** Ingeniería de Datos y Software  
**Asignatura:** Desarrollo de Datos  
**Motor de BD:** PostgreSQL  

## Integrantes del Equipo
* Emanuel Parra Gaviria
* Davet Robledo
* Tomas Duarte

---

## Estructura del Repositorio

```text
/
├── /sql
│   ├── 01_ddl.sql          # Creación de tablas, restricciones declarativas e índices
│   ├── 02_triggers.sql     # Disparadores (5 triggers)
│   ├── 03_vistas.sql       # 10 vistas (simples, combinación, agregación, control, materializadas)
│   ├── 04_procedimientos.sql # SPs y funciones del sistema
│   ├── 05_datos.sql        # Población inicial de datos de prueba
│   ├── 06_consultas.sql    # 10 consultas de negocio y verificación
│   └── 07_pruebas_negativas.sql # Pruebas con fallos esperados
├── /modelos
│   ├── MER_HemoMed.drawio / MER_HemoMed.png
│   └── MR_HemoMed.drawio  / MR_HemoMed.png
├── /evidencias
│   └── evidencias.txt      # Salidas completas de consola pgAdmin
├── Taller_HemoMed_Parra_Robledo_Duarte.docx
└── README.md
```

## Orden de Ejecución de los Scripts en PostgreSQL (pgAdmin)
1. `01_ddl.sql`
2. `02_triggers.sql`
3. `03_vistas.sql`
4. `04_procedimientos.sql`
5. `05_datos.sql`
6. `06_consultas.sql`
7. `07_pruebas_negativas.sql`
