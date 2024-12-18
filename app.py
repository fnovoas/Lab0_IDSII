from flask import Flask, render_template, redirect, url_for, request
from flask_mysqldb import MySQL
from datetime import datetime, timedelta
import os
# from dotenv import load_dotenv
from MySQLdb import IntegrityError

app = Flask(__name__ , template_folder="templates")

# app.secret_key = "Lab06"

# # Configuración de la conexión a la base de datos MySQL
# app.config['MYSQL_HOST'] = 'Lab0.mysql.pythonanywhere-services.com'
# app.config['MYSQL_USER'] = 'Lab0'
# app.config['MYSQL_PASSWORD'] = 'zaikodo321'
# app.config['MYSQL_DB'] = 'Lab0$default'
# app.config['MYSQL_CURSORCLASS'] = 'DictCursor'
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = '1234'
app.config['MYSQL_DB'] = 'Lab0'
app.config['MYSQL_CURSORCLASS'] = 'DictCursor'
# # Inicialización de la extensión MySQL
mysql = MySQL(app)

@app.route('/hello-world', methods=['GET'])
def hola():
    return "Hola muchachos"

@app.route('/')
def index():
    cursor = mysql.connection.cursor()
    cursor.execute("""  
        SELECT
            p.id_persona,
            p.nombre1,
            p.nombre2,
            p.apellido1,
            p.apellido2,
            p.dni,
            v.direccion AS direccion_residencia,
            t.nombre_tipo_documento AS tipo_documento,
            CONCAT(cf.nombre1, ' ', cf.apellido1) AS cabeza_familia
        FROM PERSONA p
        LEFT JOIN VIVIENDA v ON p.id_residencia = v.id_vivienda
        LEFT JOIN TIPO_DOCUMENTO t ON p.id_tipo_documento = t.id_tipo_documento
        LEFT JOIN PERSONA cf ON p.id_cabeza_familia = cf.id_persona
    """)
    empleados = cursor.fetchall()
    cursor.close()
    return render_template('index.html', empleados=empleados)


@app.route('/elimina/<int:id_persona>', methods=['POST'])
def elimina_empleado(id_persona):
    cursor = mysql.connection.cursor()
    cursor.execute("DELETE FROM PERSONA WHERE id_persona = %s", (id_persona,))
    mysql.connection.commit()
    cursor.close()
    return redirect(url_for('index'))


@app.route('/nuevo', methods=['GET', 'POST'])
def nuevo():
    cursor = mysql.connection.cursor()
    error_message = None
    success_message = None
    form_data = {}

    if request.method == 'POST':
        form_data = {
            'dni': request.form['dni'],
            'id_tipo_documento': request.form['id_tipo_documento'],
            'nombre1': request.form['nombre1'],
            'nombre2': request.form['nombre2'],
            'apellido1': request.form['apellido1'],
            'apellido2': request.form['apellido2'],
            'id_residencia': request.form['id_residencia'],
            'mayor_de_edad': request.form['mayor_de_edad'],
            'id_cabeza_familia': request.form['id_cabeza_familia'] or None
        }

        dni = form_data['dni']
        id_tipo_documento = form_data['id_tipo_documento']
        mayor_de_edad = bool(int(form_data['mayor_de_edad']))

        if not dni.isdigit() or int(dni) < 0 or len(dni) < 5:
            error_message = "El número de cédula debe ser positivo y tener al menos 5 dígitos."
        if mayor_de_edad and id_tipo_documento == "2":
            error_message = "No se puede seleccionar 'Tarjeta de Identidad' para mayores de edad."
        if not mayor_de_edad and id_tipo_documento == "1":
            error_message = "No se puede seleccionar 'Cédula de Ciudadanía' para menores de edad."
        
        if not error_message:
            try:
                cursor.execute(
                    """
                    INSERT INTO PERSONA (id_tipo_documento, dni, nombre1, nombre2, apellido1, apellido2, mayor_de_edad, id_cabeza_familia, id_residencia)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
                    """,
                    (
                        id_tipo_documento,
                        dni,
                        form_data['nombre1'],
                        form_data['nombre2'],
                        form_data['apellido1'],
                        form_data['apellido2'],
                        mayor_de_edad,
                        form_data['id_cabeza_familia'],
                        form_data['id_residencia']
                    )
                )
                mysql.connection.commit()
                success_message = "Persona creada exitosamente."
                form_data = {}
            except IntegrityError as e:
                error_message = "Ya existe una persona con el mismo número de cédula."

    cursor.execute("SELECT * FROM TIPO_DOCUMENTO")
    tipos_documento = cursor.fetchall()

    cursor.execute("SELECT id_vivienda, direccion FROM VIVIENDA")
    viviendas = cursor.fetchall()

    cursor.execute("SELECT id_persona, nombre1, apellido1 FROM PERSONA")
    personas = cursor.fetchall()

    cursor.close()
    return render_template(
        'nuevo.html',
        tipos_documento=tipos_documento,
        viviendas=viviendas,
        personas=personas,
        error_message=error_message,
        success_message=success_message,
        form_data=form_data
    )




@app.route('/editar/<int:id_persona>', methods=['GET', 'POST'])
def editar_empleado(id_persona):
    cursor = mysql.connection.cursor()

    if request.method == 'POST':
        # Capturar los datos del formulario
        dni = request.form['dni']
        nombre1 = request.form['nombre1']
        nombre2 = request.form['nombre2']
        apellido1 = request.form['apellido1']
        apellido2 = request.form['apellido2']
        id_residencia = request.form['id_residencia']
        id_tipo_documento = request.form['id_tipo_documento']
        mayor_de_edad = request.form['mayor_de_edad']

        # Actualizar los datos en la base de datos
        cursor.execute("""
            UPDATE PERSONA
            SET dni = %s, nombre1 = %s, nombre2 = %s, apellido1 = %s, apellido2 = %s,
                id_residencia = %s, id_tipo_documento = %s, mayor_de_edad = %s
            WHERE id_persona = %s
        """, (dni, nombre1, nombre2, apellido1, apellido2, id_residencia, id_tipo_documento, mayor_de_edad, id_persona))

        mysql.connection.commit()
        cursor.close()

        # Redirigir al índice después de guardar los cambios
        return redirect(url_for('index'))

    # Obtener los datos del empleado para prellenar el formulario
    cursor.execute("SELECT * FROM PERSONA WHERE id_persona = %s", (id_persona,))
    empleado = cursor.fetchone()

    # Obtener los tipos de documento disponibles
    cursor.execute("SELECT * FROM TIPO_DOCUMENTO")
    tipos_documento = cursor.fetchall()

    # Obtener las residencias disponibles
    cursor.execute("SELECT id_vivienda, direccion FROM VIVIENDA")
    residencias = cursor.fetchall()

    cursor.close()

    return render_template('edita.html', empleado=empleado, tipos_documento=tipos_documento, residencias=residencias)


@app.route('/nuevo_departamento', methods=['GET', 'POST'])
def nuevo_departamento():
    cursor = mysql.connection.cursor()
    error_messages = []
    success_message = None

    if request.method == 'POST':
        # Capturar los datos del formulario
        nombre_departamento = request.form['nombre_departamento']
        id_gobernador = request.form['id_gobernador'] or None

        if not error_messages:
            try:
                # Insertar el nuevo departamento en la base de datos
                cursor.execute(
                    """
                    INSERT INTO DEPARTAMENTO (nombre_departamento, id_gobernador)
                    VALUES (%s, %s)
                    """,
                    (nombre_departamento, id_gobernador)
                )
                mysql.connection.commit()
                success_message = f"Departamento '{nombre_departamento}' creado exitosamente."
            except IntegrityError as e:
                if "nombre_departamento" in str(e):
                    error_messages.append(f"El departamento '{nombre_departamento}' ya existe en la base de datos.")
                if "unique_gobernador" in str(e):
                    error_messages.append("La persona seleccionada ya es gobernador de otro departamento.")
        
        cursor.execute("SELECT id_persona, nombre1, apellido1 FROM PERSONA")
        personas = cursor.fetchall()
        cursor.close()
        return render_template('departamento.html', personas=personas, success_message=success_message, error_message=" ".join(error_messages) if error_messages else None)

    # Obtener la lista de personas para asignar como gobernador
    cursor.execute("SELECT id_persona, nombre1, apellido1 FROM PERSONA")
    personas = cursor.fetchall()

    cursor.close()
    return render_template('departamento.html', personas=personas)

@app.route('/editar_departamento/<int:id_departamento>', methods=['GET', 'POST'])
def editar_departamento(id_departamento):
    cursor = mysql.connection.cursor()

    if request.method == 'POST':
        # Capturar los datos del formulario
        nombre_departamento = request.form['nombre_departamento']
        id_gobernador = request.form['id_gobernador'] or None

        # Actualizar el departamento en la base de datos
        cursor.execute("""
            UPDATE DEPARTAMENTO
            SET nombre_departamento = %s, id_gobernador = %s
            WHERE id_departamento = %s
        """, (nombre_departamento, id_gobernador, id_departamento))

        mysql.connection.commit()
        cursor.close()

        return redirect(url_for('ver_departamentos'))

    # Obtener los datos del departamento
    cursor.execute("SELECT * FROM DEPARTAMENTO WHERE id_departamento = %s", (id_departamento,))
    departamento = cursor.fetchone()

    # Obtener la lista de personas para asignar como gobernador
    cursor.execute("SELECT id_persona, nombre1, apellido1 FROM PERSONA")
    personas = cursor.fetchall()

    cursor.close()
    return render_template('editar_departamento.html', departamento=departamento, personas=personas)




@app.route('/nuevo_municipio', methods=['GET', 'POST'])
def nuevo_municipio():
    cursor = mysql.connection.cursor()

    if request.method == 'POST':
        # Capturar los datos del formulario
        nombre_municipio = request.form['nombre_municipio']
        id_departamento = request.form['id_departamento']

        # Insertar el nuevo municipio en la base de datos
        cursor.execute(
            """
            INSERT INTO MUNICIPIO (nombre_municipio, id_departamento)
            VALUES (%s, %s)
            """,
            (nombre_municipio, id_departamento)
        )

        mysql.connection.commit()
        cursor.close()
        return redirect(url_for('index'))

    # Obtener la lista de departamentos para asignar al municipio
    cursor.execute("SELECT id_departamento, nombre_departamento FROM DEPARTAMENTO")
    departamentos = cursor.fetchall()

    cursor.close()
    return render_template('municipio.html', departamentos=departamentos)

@app.route('/ver_departamentos', methods=['GET'])
def ver_departamentos():
    cursor = mysql.connection.cursor()

    # Consultar los departamentos y sus gobernadores
    cursor.execute("""
        SELECT d.id_departamento, d.nombre_departamento, p.nombre1, p.apellido1
        FROM DEPARTAMENTO d
        LEFT JOIN PERSONA p ON d.id_gobernador = p.id_persona
    """)
    departamentos = cursor.fetchall()
    cursor.close()

    # Obtener el mensaje de error si está presente en la URL
    error_message = request.args.get('error_message')

    return render_template('ver_departamentos.html', departamentos=departamentos, error_message=error_message)

@app.route('/ver_viviendas', methods=['GET'])
def ver_viviendas():
    cursor = mysql.connection.cursor()
    cursor.execute("""
        SELECT
            v.id_vivienda,
            v.direccion,
            m.nombre_municipio
        FROM VIVIENDA v
        LEFT JOIN MUNICIPIO m ON v.id_municipio = m.id_municipio
    """)
    viviendas = cursor.fetchall()
    cursor.close()
    return render_template('ver_viviendas.html', viviendas=viviendas)

# Ruta para eliminar una vivienda
@app.route('/eliminar_vivienda/<int:id_vivienda>', methods=['POST'])
def eliminar_vivienda(id_vivienda):
    cursor = mysql.connection.cursor()

    # Eliminar la vivienda de la base de datos
    cursor.execute("DELETE FROM VIVIENDA WHERE id_vivienda = %s", (id_vivienda,))
    mysql.connection.commit()
    cursor.close()

    return redirect(url_for('ver_viviendas'))

# Ruta para editar una vivienda
@app.route('/editar_vivienda/<int:id_vivienda>', methods=['GET', 'POST'])
def editar_vivienda(id_vivienda):
    cursor = mysql.connection.cursor()

    if request.method == 'POST':
        # Capturar los datos del formulario
        direccion = request.form['direccion']
        id_municipio = request.form['id_municipio'] or None

        # Actualizar la vivienda en la base de datos
        cursor.execute("""
            UPDATE VIVIENDA
            SET direccion = %s, id_municipio = %s
            WHERE id_vivienda = %s
        """, (direccion, id_municipio, id_vivienda))

        mysql.connection.commit()
        cursor.close()

        return redirect(url_for('ver_viviendas'))

    # Obtener los datos de la vivienda
    cursor.execute("SELECT * FROM VIVIENDA WHERE id_vivienda = %s", (id_vivienda,))
    vivienda = cursor.fetchone()

    # Obtener la lista de municipios
    cursor.execute("SELECT id_municipio, nombre_municipio FROM MUNICIPIO")
    municipios = cursor.fetchall()

    cursor.close()
    return render_template('editar_vivienda.html', vivienda=vivienda, municipios=municipios)


@app.route('/crear_vivienda', methods=['GET', 'POST'])
def crear_vivienda():
    if request.method == 'POST':
        direccion = request.form['direccion']
        id_municipio = request.form['id_municipio']

        cursor = mysql.connection.cursor()
        cursor.execute("""
            INSERT INTO VIVIENDA (direccion, id_municipio)
            VALUES (%s, %s)
        """, (direccion, id_municipio))
        mysql.connection.commit()
        cursor.close()

        return redirect(url_for('index'))

    cursor = mysql.connection.cursor()
    cursor.execute("SELECT id_municipio, nombre_municipio FROM MUNICIPIO")
    municipios = cursor.fetchall()
    cursor.close()

    return render_template('crear_viviendas.html', municipios=municipios)

@app.route('/ver_municipios', methods=['GET'])
def ver_municipios():
    cursor = mysql.connection.cursor()
    cursor.execute("""
        SELECT
            m.id_municipio,
            m.nombre_municipio,
            d.nombre_departamento
        FROM MUNICIPIO m
        JOIN DEPARTAMENTO d ON m.id_departamento = d.id_departamento
    """)
    municipios = cursor.fetchall()
    cursor.close()
    # Obtener el mensaje de error si está presente
    error_message = request.args.get('error_message', None)

    return render_template('ver_municipios.html', municipios=municipios,error_message=error_message)

@app.route('/eliminar_municipios/<int:id_municipio>', methods=['POST'])
def eliminar_municipios(id_municipio):
    cursor = mysql.connection.cursor()
    error_message = None

    try:
        # Intentar eliminar el municipio
        cursor.execute("DELETE FROM MUNICIPIO WHERE id_municipio = %s", (id_municipio,))
        mysql.connection.commit()
    except Exception as e:
        # Capturar el error y almacenar el mensaje
        error_message = f"No se puede eliminar el municipio ya que está enlazado a una vivienda"
    finally:
        cursor.close()

    # Redirigir con el mensaje de error si ocurre
    if error_message:
        return redirect(url_for('ver_municipios', error_message=error_message))
    else:
        return redirect(url_for('ver_municipios'))

@app.route('/eliminar_departamento/<int:id_departamento>', methods=['POST'])
def eliminar_departamento(id_departamento):
    cursor = mysql.connection.cursor()
    error_message = None

    try:
        # Intentar eliminar el departamento
        cursor.execute("DELETE FROM DEPARTAMENTO WHERE id_departamento = %s", (id_departamento,))
        mysql.connection.commit()
    except Exception:
        # Establecer el mensaje de error
        error_message = "No se puede eliminar el departamento ya que está enlazado a un municipio."
    finally:
        cursor.close()

    # Redirigir con el mensaje de error si ocurre
    if error_message:
        return redirect(url_for('ver_departamentos', error_message=error_message))
    else:
        return redirect(url_for('ver_departamentos'))

@app.route('/editar_municipio/<int:id_municipio>', methods=['GET', 'POST'])
def editar_municipio(id_municipio):
    cursor = mysql.connection.cursor()

    if request.method == 'POST':
        # Capturar los datos del formulario
        nombre_municipio = request.form['nombre_municipio']
        id_departamento = request.form['id_departamento']

        # Actualizar el municipio en la base de datos
        cursor.execute("""
            UPDATE MUNICIPIO
            SET nombre_municipio = %s, id_departamento = %s
            WHERE id_municipio = %s
        """, (nombre_municipio, id_departamento, id_municipio))

        mysql.connection.commit()
        cursor.close()

        return redirect(url_for('ver_municipios'))

    # Obtener los datos del municipio
    cursor.execute("""
        SELECT m.id_municipio, m.nombre_municipio, m.id_departamento, d.nombre_departamento
        FROM MUNICIPIO m
        JOIN DEPARTAMENTO d ON m.id_departamento = d.id_departamento
        WHERE m.id_municipio = %s
    """, (id_municipio,))
    municipio = cursor.fetchone()

    # Obtener la lista de departamentos para el selector
    cursor.execute("SELECT id_departamento, nombre_departamento FROM DEPARTAMENTO")
    departamentos = cursor.fetchall()

    cursor.close()
    return render_template('editar_municipio.html', municipio=municipio, departamentos=departamentos)

@app.route('/conocenos', methods=['GET'])
def conocenos():
    return render_template('conocenos.html')
@app.route('/politica', methods=['GET'])
def politica():
    return render_template('politica.html')
#####
if __name__ == '__main__':
    app.run(debug=True)
