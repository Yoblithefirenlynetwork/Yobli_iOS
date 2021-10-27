# NOMBRE

## YOBLI - IOS

## Descripción

Yobli es un proyecto desarrollado por Brounie SA de CV, permite la creación e inscripción a Cursos, Servicios, Voluntariados o lectura de Blogs.

## Características

* Conexión a Base de Datos [Parse](https://docs.parseplatform.org/ios/guide/)
* Conexión a Base de Datos [Firebase](https://firebase.google.com/docs/ios/setup?hl=es)
* Conexión a [Conekta](https://github.com/conekta/conekta-ios) para Pagos
* Inicio/Creación de Cuenta ( Correo ó Facebook ) - **Parse/Firebase**
* Selección de Cuenta **_( User / Yober )_**
* Recuperación de contraseña - **Firebase**
* Chat - **Firebase**
* Creación de Cursos, Voluntariados, Servicios - **Parse**
* Registró de Tarjetas - **Parse/Conekta**
* Inscripción a Cursos, Servicios - **Parse/Conekta**
* Inscripción a Voluntariados - **Parse**
* Envío y Recepción de Notificaciones - **Parse**
* Edición de Disponibilidad y Bloqueo de días en Agenda - _Yober_

## Componentes Pod, no Firebase/Parse

* **FSCalendar**
* **IQKeyboardManagerSwift**
* **MBProgressHUD**
* **MessageKit**

## Contribuir

Asegurar que cualquier cambio antes de versión comercial, primero pase por la rama **_develop_**, en caso de no existir, crearla.

## Características Faltantes

* _Envío y chequeo de SMS con código para verificación de celular_
* _Verificación de Correo, puede ser con código al momento de ponerlo o después de la creación_