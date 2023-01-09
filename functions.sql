------------------------------------------------------
-- Populates serviceTbl

CREATE OR REPLACE FUNCTION addService (
    type               VARCHAR ( 128 ) NOT NULL, -- Plotted, uses extra markers, fancy stamps, etc.
    data           VARCHAR ( 1024 ) NOT NULL -- {data:url}
) RETURNS VOID AS $$

BEGIN
    INSERT INTO serviceTbl (
        type,
        data
    )
    VALUES (
        type,
        data
    );

END;
$$ language plpgsql


------------------------------------------------------
-- Calls addItem and addProduct

CREATE OR REPLACE FUNCTION addItemProduct (
    -- addItem Params
    supplier_id        INT,
    sku                VARCHAR ( 30 ),
    restock_url        VARCHAR ( 256 ),
    msrp               FLOAT,
    discount           FLOAT,
    price              FLOAT,
    quantity           INT,
    updated_by         INT,
    -- addProduct Params
    title              VARCHAR,
    category_id        INT,
    summary            VARCHAR,
    type               VARCHAR,
    image_url          VARCHAR,
    thumbnail_url      VARCHAR,
    content            VARCHAR
) RETURNS VOID AS $$

BEGIN
    SELECT addItem (
        supplier_id,
        sku,
        restock_url,
        msrp,
        discount,
        price,
        quantity,
        updated_by
    ) INTO item_id;

    SELECT addProduct (
        item_id,
        title,
        category_id,
        summary,
        type,
        image_url,
        thumbnail_url,
        content
    );

END;
$$ language plpgsql


------------------------------------------------------
-- Populates itemTbl

CREATE OR REPLACE FUNCTION addItem (
    supplier_id        INT,
    sku                VARCHAR ( 30 ),
    restock_url        VARCHAR ( 256 ),
    msrp               FLOAT,
    discount           FLOAT,
    price              FLOAT,
    quantity           INT,
    updated_by         INT
) RETURNS INT AS $$

BEGIN
    INSERT INTO itemTbl (
        supplier_id,
        sku,
        restock_url,
        msrp,
        discount,
        price,
        quantity,
        available,
        created,
        updated,
        updated_by
    )
    VALUES (
        COALESCE ( supplier_id, 2 ),
        sku,
        restock_url,
        msrp,
        discount,
        price,
        quantity,
        quantity, -- Starts with the same number as quantity
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP,
        updated_by
    ) RETURNING id INTO item_id;
    RETURN item_id;

END;
$$ language plpgsql


------------------------------------------------------
-- Populates productTbl

CREATE OR REPLACE FUNCTION addProduct (
    item_id            INT,
    title              VARCHAR,
    category_id        INT,
    summary            VARCHAR,
    type               VARCHAR,
    image_url          VARCHAR,
    thumbnail_url      VARCHAR,
    content            VARCHAR 
) RETURNS VOID AS $$

BEGIN
    INSERT INTO productTbl (
        item_id,
        title,
        category_id,
        summary,
        type,
        image_url,
        thumbnail_url,
        created,
        updated,
        content
    )
    VALUES (
        item_id,
        title,
        category_id,
        summary,
        type,
        image_url,
        thumbnail_url,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP,
        content
    );

END;
$$ language plpgsql


------------------------------------------------------
-- Populates supplierTbl

CREATE OR REPLACE FUNCTION addSupplier (
    brand              VARCHAR ( 32 ),
    supplier_url       VARCHAR ( 256 ),
    summary            VARCHAR ( 256 ),
    updated_by         INT,
) RETURNS VOID AS $$

BEGIN
    INSERT INTO supplierTbl (
        brand,
        supplier_url,
        summary,
        created,
        updated,
        updated_by
    )
    VALUES (
        brand,
        supplier_url,
        summary,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP,
        COALESCE ( updated_by, 0 ) 
    );

END;
$$ language plpgsql


------------------------------------------------------
-- Populates categoryTbl

CREATE OR REPLACE FUNCTION addCategory (
    parent_id          INT,
    title              VARCHAR ( 32 )
) RETURNS VOID AS $$

BEGIN
    INSERT INTO categoryTbl (
        parent_id,
        title
    )
    VALUES (
        COALESCE ( parent_id, -1 ),
        title
    );

END;
$$ language plpgsql


------------------------------------------------------
-- 