DROP DATABASE IF EXISTS db_feasverse;
CREATE DATABASE db_feasverse;
USE db_feasverse;
 
CREATE TABLE tb_niveles
(
	id_nivel INT PRIMARY KEY,
	nivel VARCHAR(20)
);
 
CREATE TABLE tb_trabajadores
(
	id_trabajador INT PRIMARY KEY,
	nombre_trabajador VARCHAR(20),
	apellido_trabajador VARCHAR(20),
	dui_trabajador  VARCHAR(10),
	telefono_trabajador  VARCHAR(9),
	correo_trabajador VARCHAR(30),
	clave_trabajador VARCHAR(30),
	fecha_de_registro DATE,
	fecha_de_nacimiento DATE,
	id_nivel INT,
	estado_trabajador BOOLEAN
);
##------------------------------------------------------FORANEAS (TRABAJADORES)
ALTER TABLE tb_trabajadores
ADD FOREIGN KEY (id_nivel) REFERENCES tb_niveles(id_nivel);
##------------------------------------------------------
 
CREATE TABLE tb_marcas
(
	id_marca INT PRIMARY KEY,
	nombre_marca VARCHAR(20),
	foto_marca VARCHAR(20),
	descripcion_marca VARCHAR(100)
);
 
CREATE TABLE tb_zapatos
(
	id_zapato INT PRIMARY KEY,
	id_trabajador INT,
	id_marca INT,
	nombre_zapato VARCHAR(20),
	genero_zapato INT,
	descripcion_zapato VARCHAR(200),
	estado_zapato BOOLEAN
);
##------------------------------------------------------FORANEAS (ZAPATOS)
ALTER TABLE tb_zapatos
ADD FOREIGN KEY (id_trabajador) REFERENCES tb_trabajadores(id_trabajador);
 
ALTER TABLE tb_zapatos
ADD FOREIGN KEY (id_marca) REFERENCES tb_marcas(id_marca);
##------------------------------------------------------
 
CREATE TABLE tb_colores
(
	id_color INT PRIMARY KEY,
	nombre_color VARCHAR(20)
);
 
CREATE TABLE tb_detalles_colores_zapatos
(
	id_detalle_color_zapato INT PRIMARY KEY,
	foto_zapato_color VARCHAR(20),
	id_color INT 
);
##------------------------------------------------------FORANEAS (DETALLES COLOR ZAPATO)
ALTER TABLE tb_detalles_colores_zapatos ADD FOREIGN KEY (id_color) 
REFERENCES tb_colores(id_color);
##------------------------------------------------------
 
CREATE TABLE tb_mas_colores_de_zapatos
(
	id_mas_color_de_zapato INT PRIMARY KEY,
	id_color INT,
	id_detalle_color_zapato INT
);
##------------------------------------------------------FORANEAS (MAS COLORES ZAPATO)
ALTER TABLE tb_mas_colores_de_zapatos
ADD FOREIGN KEY (id_detalle_color_zapato) REFERENCES tb_detalles_colores_zapatos(id_detalle_color_zapato);
 
ALTER TABLE tb_mas_colores_de_zapatos
ADD FOREIGN KEY (id_color) REFERENCES tb_colores(id_color);
##------------------------------------------------------
 
CREATE TABLE tb_tallas
(
	id_talla INT PRIMARY KEY,
	tamaño_talla VARCHAR(4)
);
 
CREATE TABLE tb_detalle_zapatos
(
	id_detalle_zapato INT PRIMARY KEY,
	id_zapato INT, 
	id_talla INT,
	cantidad_zapato INT,
	id_detalle_color_zapato INT,
	precio_unitario_zapato DOUBLE
);
##------------------------------------------------------FORANEAS (DETALLES ZAPATO)
ALTER TABLE tb_detalle_zapatos
ADD FOREIGN KEY (id_talla) REFERENCES tb_tallas(id_talla);
 
ALTER TABLE tb_detalle_zapatos
ADD FOREIGN KEY (id_zapato) REFERENCES tb_zapatos(id_zapato);
 
ALTER TABLE tb_detalle_zapatos
ADD FOREIGN KEY (id_detalle_color_zapato) REFERENCES tb_detalles_colores_zapatos(id_detalle_color_zapato);
##------------------------------------------------------
 
CREATE TABLE tb_clientes
(
	id_cliente INT PRIMARY KEY, 
	nombre_cliente VARCHAR(20),
	apellido_cliente VARCHAR(20),
	dui_cliente VARCHAR(10),
	telefono_cliente VARCHAR(9),
	correo_cliente VARCHAR(30),
	direccion_cliente VARCHAR(30),
	clave_cliente VARCHAR(30),
	fecha_de_registro DATE, 
	fecha_de_nacimiento DATE,
	estado_cliente BOOLEAN
);
 
CREATE TABLE tb_comentarios
(
	id_comentario INT PRIMARY KEY,
	descripcion_comentario VARCHAR(165) NULL,
	calificacion_comentario INT not NULL,
	estado_comentario BOOLEAN
);
 
CREATE TABLE tb_departamentos
(
	id_departamento INT PRIMARY KEY,
    nombre_departamento VARCHAR(100)
);
 
CREATE TABLE tb_costos_de_envio_por_departamento
(
	id_costo_de_envio_por_departamento INT PRIMARY KEY,
    id_departamento INT,
    costo_de_envio DOUBLE
);
##------------------------------------------------------FORANEAS (COSTOS DE ENVIO)
ALTER TABLE tb_costos_de_envio_por_departamento
ADD FOREIGN KEY (id_departamento) REFERENCES tb_departamentos(id_departamento);
##------------------------------------------------------
 
CREATE TABLE tb_pedidos_clientes
(
	id_pedido_cliente INT PRIMARY KEY,
	id_cliente INT,
	id_repartidor INT,
	estado_pedido VARCHAR(20),
	precio_total DOUBLE,
	fecha_de_inicio DATE,
	fecha_de_entrega DATE,
    id_costo_de_envio_por_departamento INT 
);
##------------------------------------------------------FORANEAS (PEDIDOS CLIENTES)
ALTER TABLE tb_pedidos_clientes
ADD FOREIGN KEY (id_cliente) REFERENCES tb_clientes(id_cliente);
 
ALTER TABLE tb_pedidos_clientes
ADD FOREIGN KEY (id_repartidor) REFERENCES tb_trabajadores(id_trabajador);
 
ALTER TABLE tb_pedidos_clientes
ADD FOREIGN KEY (id_costo_de_envio_por_departamento) REFERENCES tb_costos_de_envio_por_departamento(id_costo_de_envio_por_departamento);
##------------------------------------------------------
 
CREATE TABLE tb_detalles_pedidos
(
	id_detalles_pedido INT PRIMARY KEY,
	id_pedido_cliente INT,
	id_detalle_zapato INT,
	cantidad_pedido INT,
	precio_del_zapato DOUBLE,
    id_comentario INT
);
##------------------------------------------------------FORANEAS (DETALLES PEDIDOS)
ALTER TABLE tb_detalles_pedidos
ADD FOREIGN KEY (id_detalle_zapato) REFERENCES tb_detalle_zapatos(id_detalle_zapato);
 
ALTER TABLE tb_detalles_pedidos
ADD FOREIGN KEY (id_pedido_cliente) REFERENCES tb_pedidos_clientes(id_pedido_cliente);
 
ALTER TABLE tb_detalles_pedidos
ADD FOREIGN KEY (id_comentario) REFERENCES tb_comentarios(id_comentario);
##------------------------------------------------------
 
##-----TRIGERR
DELIMITER //
 
CREATE TRIGGER actualizar_existencias_zapato
AFTER INSERT ON tb_detalles_pedidos
FOR EACH ROW
BEGIN
    UPDATE tb_detalle_zapatos
    SET cantidad_zapato = cantidad_zapato - NEW.cantidad_pedido
    WHERE id_detalle_zapato = NEW.id_detalle_zapato;
END
 
//
DELIMITER ;
 
#----PROCEDIMIENTO
DELIMITER //
CREATE PROCEDURE sp_realizar_pedido(
    IN p_id_cliente INT,
    IN p_id_repartidor INT,
    IN p_estado_pedido VARCHAR(20),
    IN p_precio_total DOUBLE,
    IN p_fecha_inicio DATE,
    IN p_fecha_entrega DATE,
    IN p_id_costo_envio INT,
    IN p_id_detalle_zapato INT,
    IN p_cantidad_pedido INT,
    IN p_precio_del_zapato DOUBLE,
    IN p_id_comentario INT,
    IN p_descripcion_comentario VARCHAR(165),
    IN p_calificacion_comentario INT,
    IN p_estado_comentario BOOLEAN
)
BEGIN
    DECLARE v_id_pedido INT;
    -- Insertar en la tabla de pedidos
    INSERT INTO tb_pedidos_clientes (id_cliente, id_repartidor, estado_pedido, precio_total, fecha_de_inicio, fecha_de_entrega, id_costo_de_envio_por_departamento)
    VALUES (p_id_cliente, p_id_repartidor, p_estado_pedido, p_precio_total, p_fecha_inicio, p_fecha_entrega, p_id_costo_envio);
    -- Obtener el ID del último pedido insertado
    SET v_id_pedido = LAST_INSERT_ID();
    -- Insertar detalles del pedido
    INSERT INTO tb_detalles_pedidos (id_pedido_cliente, id_detalle_zapato, cantidad_pedido, precio_del_zapato, id_comentario)
    VALUES (v_id_pedido, p_id_detalle_zapato, p_cantidad_pedido, p_precio_del_zapato, p_id_comentario);
    -- Insertar comentario del pedido
    INSERT INTO tb_comentarios (id_comentario, descripcion_comentario, calificacion_comentario, estado_comentario)
    VALUES (p_id_comentario, p_descripcion_comentario, p_calificacion_comentario, p_estado_comentario);
END //
DELIMITER ;
 
#-------FUNCION
DELIMITER //
CREATE FUNCTION calcular_precio_total(id_pedido_cliente INT) RETURNS DOUBLE
BEGIN
    DECLARE total DOUBLE;
    SELECT SUM(d.cantidad_pedido * dz.precio_unitario_zapato) INTO total
    FROM tb_detalles_pedidos d
    INNER JOIN tb_detalle_zapatos dz ON d.id_detalle_zapato = dz.id_detalle_zapato
    WHERE d.id_pedido_cliente = id_pedido_cliente;
    RETURN total;
END //
DELIMITER ;