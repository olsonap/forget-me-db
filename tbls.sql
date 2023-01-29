-----------------------------------------------
-- User-related Tables

CREATE TABLE if not exists usuarioTbl (
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


CREATE TABLE if not exists addressTbl (
    id                 serial PRIMARY KEY,
    line1              VARCHAR ( 46 ) NOT NULL,
    line2              VARCHAR ( 46 ),
    city               VARCHAR ( 50 ) NOT NULL,
    state              VARCHAR ( 50 ) NOT NULL,
    country            VARCHAR ( 50 ) NOT NULL,
    created            TIMESTAMP NOT NULL,
    updated            TIMESTAMP
);


CREATE TABLE if not exists addressBookTbl (
    user_id            INT NOT NULL REFERENCES usuarioTbl ( id ),
    contact_id         INT NOT NULL REFERENCES usuarioTbl ( id ),
    address_id         INT NOT NULL REFERENCES addressTbl ( id )
);


CREATE TABLE if not exists cardTbl (
    id                 serial PRIMARY KEY,
    card_type          VARCHAR ( 2 ) NOT NULL, -- MC, VS, AX, DS, etc.
    number             VARCHAR ( 16 ) NOT NULL,
    csv                INT NOT NULL,
    exp                DATE NOT NULL
);


CREATE TABLE if not exists walletTbl (
    user_id            INT NOT NULL REFERENCES usuarioTbl ( id ),
    address_id         INT NOT NULL REFERENCES addressTbl ( id ),
    card_id            INT NOT NULL REFERENCES cardTbl ( id )
);

-----------------------------------------------
-- Order-related Tables

CREATE TABLE if not exists orderTbl (
    id                 serial PRIMARY KEY,
    user_id            INT NOT NULL REFERENCES usuarioTbl ( id ),
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


CREATE TABLE if not exists orderItemTbl (
    id                 serial PRIMARY KEY,
    item_id            INT NOT NULL REFERENCES itemTbl ( id ),
    product_id         INT NOT NULL REFERENCES productTbl ( id ),
    order_id           INT NOT NULL REFERENCES orderTbl ( id ),
    discount           FLOAT NOT NULL,
    quantity           INT NOT NULL,
    delivery_address_id    INT NOT NULL REFERENCES addressTbl ( id ),
    sender_address_id      INT NOT NULL REFERENCES addressTbl ( id ),
    in_time_for        DATE NOT NULL -- This is the last acceptable delivery date
);


CREATE TABLE if not exists serviceTbl (
    id                 serial PRIMARY KEY,
    type               VARCHAR ( 128 ) NOT NULL, -- Plotted, used extra markers, fancy stamps, etc.
    data               VARCHAR ( 1024 ) NOT NULL, -- {data:url, location:(x,y)}
    service_received   BOOLEAN DEFAULT FALSE -- Meant to indicate whether the service has been planned for yet
);


CREATE TABLE if not exists transactionTbl (
    id                 serial PRIMARY KEY,
    user_id            INT NOT NULL REFERENCES usuarioTbl ( id ),
    order_id           INT NOT NULL REFERENCES orderTbl ( id ),
    type               VARCHAR ( 10 ) NOT NULL, -- inventory order, sale payment, sale refund, other?
    mode               VARCHAR ( 10 ) NOT NULL, -- CC, paypal, stripe, venmo, etc.
    status             VARCHAR ( 10 ) NOT NULL, -- new, cancelled, failed, pending, declined, complete
    created            TIMESTAMP NOT NULL,
    updated            TIMESTAMP,
    content            VARCHAR ( 50 ) -- brief description of transaction, e.g. reason for refund, cancellation, failure, etc.
);

-----------------------------------------------
-- Product/service-related Tables

CREATE TABLE if not exists itemTbl (
    id                 serial PRIMARY KEY,
    supplier_id        INT NOT NULL, -- REFERENCES supplierTbl ( id ),
    sku                VARCHAR ( 30 ) NOT NULL,
    restock_url        VARCHAR ( 256 ) NOT NULL,
    msrp               FLOAT NOT NULL,
    discount           FLOAT,
    price              FLOAT,
    quantity           INT NOT NULL, -- total quantity
    sold               INT DEFAULT 0, -- total claimed
    defective          INT DEFAULT 0, -- total unusable due to defects or failed processing
    available          INT NOT NULL, -- total available = quantity - sold - defective
    created            TIMESTAMP NOT NULL,
    updated            TIMESTAMP,
    updated_by         INT -- REFERENCES usuarioTbl ( id )
);


CREATE TABLE if not exists productTbl (
    id                 serial PRIMARY KEY,
    item_id            INT NOT NULL REFERENCES itemTbl ( id ),
    title              VARCHAR ( 128 ) NOT NULL,
    category_id        INT NOT NULL REFERENCES categoryTbl ( id ),
    summary            VARCHAR ( 256 ) NOT NULL,
    type               VARCHAR ( 16 ) NOT NULL,
    image_url          VARCHAR ( 256 ) NOT NULL,
    thumbnail_url      VARCHAR ( 256 ) NOT NULL,
    created            TIMESTAMP NOT NULL,
    updated            TIMESTAMP,
    content            VARCHAR ( 256 ) -- Any additional information about the product
);


CREATE TABLE if not exists supplierTbl (
    id                 serial PRIMARY KEY,
    brand              VARCHAR ( 32 ) NOT NULL,
    supplier_url       VARCHAR ( 256 ) NOT NULL,
    summary            VARCHAR ( 256 ) NOT NULL,
    created            TIMESTAMP NOT NULL,
    updated            TIMESTAMP,
    updated_by         INT NOT NULL
);


CREATE TABLE if not exists categoryTbl (
    id                 serial PRIMARY KEY,
    parent_id          INT NOT NULL REFERENCES categoryTbl ( id ),
    title              VARCHAR ( 32 ) NOT NULL
);
INSERT INTO categoryTbl (id, parent_id, title) VALUES (-1,-1,'No Parent');
