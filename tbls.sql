CREATE TABLE if not exists usuario (
    id                 serial PRIMARY KEY,
    fname              VARCHAR ( 20 ) NOT NULL,
    lname              VARCHAR ( 20 ) NOT NULL,
    username           VARCHAR ( 50 ) UNIQUE NOT NULL,
    email              VARCHAR ( 255 ) UNIQUE NOT NULL,
    phone_id           INT NOT NULL,
    address_id         INT NOT NULL,
    created            TIMESTAMP NOT NULL,
    updated            TIMESTAMP,
    last_login         TIMESTAMP,
    is_admin           BOOLEAN DEFAULT FALSE,
    is_user            BOOLEAN DEFAULT FALSE,
    birthdate          DATE
);


CREATE TABLE if not exists address (
    id                 serial PRIMARY KEY,
    line1              VARCHAR ( 46 ) NOT NULL,
    line2              VARCHAR ( 46 ),
    city               VARCHAR ( 50 ) NOT NULL,
    state              VARCHAR ( 50 ) NOT NULL,
    country            VARCHAR ( 50 ) NOT NULL,
    created            TIMESTAMP NOT NULL,
    updated            TIMESTAMP
);


CREATE TABLE if not exists address_book (
    user_id            serial NOT NULL REFERENCES usuario ( id ),
    contact_id         serial NOT NULL REFERENCES usuario ( id ),
    address_id         serial NOT NULL REFERENCES address ( id )
);


CREATE TABLE if not exists card (
    id                 serial PRIMARY KEY,
    card_type          VARCHAR ( 2 ) NOT NULL, -- MC, VS, AX, DS, etc.
    number             VARCHAR ( 16 ) NOT NULL,
    csv                INT NOT NULL,
    exp                DATE NOT NULL
);


CREATE TABLE if not exists wallet (
    user_id            serial NOT NULL REFERENCES usuario ( id ),
    address_id         serial NOT NULL REFERENCES address ( id ),
    card_id            serial NOT NULL REFERENCES card ( id )
);


CREATE TABLE if not exists orderTbl (
    id                 serial PRIMARY KEY,
    user_id            serial NOT NULL REFERENCES usuario(id),
    type               VARCHAR ( 10 ) NOT NULL, -- inventory order, sale, other
    status             VARCHAR ( 10 ) NOT NULL, -- cancelled, failed (due to bad address or error), declined (payment), pending, prepared, shipped, delivered
    subtotal           FLOAT NOT NULL,
    item_discount      FLOAT NOT NULL,
    tax                FLOAT NOT NULL,
    shipping           FLOAT NOT NULL,
    total              FLOAT NOT NULL,
    promo              FLOAT NOT NULL,
    discount           FLOAT NOT NULL,
    grand_total        FLOAT NOT NULL,
    created            TIMESTAMP NOT NULL,
    updated            TIMESTAMP
);


CREATE TABLE if not exists transaction (
    id                 serial PRIMARY KEY,
    user_id            serial NOT NULL REFERENCES usuario(id),
    order_id           serial NOT NULL REFERENCES orderTbl(id),
    type               VARCHAR ( 10 ) NOT NULL, -- inventory order, sale payment, sale refund, other?
    mode               VARCHAR ( 10 ) NOT NULL, -- CC, paypal, stripe, venmo, etc.
    status             VARCHAR ( 10 ) NOT NULL, -- new, cancelled, failed, pending, declined, complete
    created            TIMESTAMP NOT NULL,
    updated            TIMESTAMP,
    content            VARCHAR ( 50 ) -- brief description of transaction, e.g. reason for refund, cancellation, failure, etc.
);


CREATE TABLE if not exists item (
    id                 serial PRIMARY KEY,
    supplier_id        serial NOT NULL REFERENCES supplier ( id ),
    sku                VARCHAR ( 30 ) NOT NULL,
    restock_url        VARCHAR ( 256 ) NOT NULL,
    msrp               FLOAT NOT NULL,
    discount           FLOAT,
    price              FLOAT,
    quantity           INT NOT NULL, -- total quantity
    sold               INT NOT NULL, -- total claimed
    defective          INT NOT NULL, -- total unusable due to defects or failed processing
    available          INT NOT NULL, -- total available = quantity - sold - defective
    created            TIMESTAMP NOT NULL,
    updated            TIMESTAMP,
    updated_by         serial REFERENCES usuario ( id )
);


CREATE TABLE if not exists order_item (
    id                 serial PRIMARY KEY,
    item_id            serial NOT NULL REFERENCES item ( id ),
    product_id         serial NOT NULL REFERENCES product ( id ),
    order_id           serial NOT NULL REFERENCES orderTbl ( id ),
    discount           FLOAT NOT NULL,
    quantity           INT NOT NULL,
    service_id         serial NOT NULL REFERENCES service ( id ),
    delivery_address_id    serial NOT NULL REFERENCES address ( id ),
    sender_address_id      serial NOT NULL REFERENCES address ( id ),
    in_time_for        DATE NOT NULL -- This is the last acceptable delivery date
);


CREATE TABLE if not exists product (
    id                 serial PRIMARY KEY,
    item_id            serial NOT NULL REFERENCES item ( id ),
    title              VARCHAR ( 128 ) NOT NULL,
    category_id        serial NOT NULL REFERENCES category ( id ),
    summary            VARCHAR ( 256 ) NOT NULL,
    type               VARCHAR ( 16 ) NOT NULL,
    image_url          VARCHAR ( 256 ) NOT NULL,
    thumbnail_url      VARCHAR ( 256 ) NOT NULL,
    created            TIMESTAMP NOT NULL,
    updated            TIMESTAMP,
    content            VARCHAR ( 256 ) -- Any additional information about the product
);


CREATE TABLE if not exists supplier (
    id                 serial PRIMARY KEY,
    brand              VARCHAR ( 32 ) NOT NULL,
    supplier_url       VARCHAR ( 256 ) NOT NULL,
    summary            VARCHAR ( 256 ) NOT NULL,
    created            TIMESTAMP NOT NULL,
    updated            TIMESTAMP
);


CREATE TABLE if not exists service (
    id                 serial PRIMARY KEY,
    type               VARCHAR ( 32 ) NOT NULL, -- Plotted, used extra markers, fancy stamps, etc.
    data_url           VARCHAR ( 256 ) NOT NULL,
    location           VARCHAR ( 8 ) NOT NULL, -- X Y coordinate on sheet, in pixels, e.g. 1200 across by 1456 pixels high
    service_received   BOOLEAN DEFAULT FALSE -- Meant to indicate whether the service has been planned for yet
);


CREATE TABLE if not exists category (
    id                 serial PRIMARY KEY,
    parent_id          serial REFERENCES category(id),
    title              VARCHAR ( 32 ) NOT NULL
);
