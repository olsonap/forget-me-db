CREATE OR REPLACE FUNCTION addItem(
    supplier_id INT,
    sku VARCHAR(30),
    restock_url VARCHAR(256),
    msrp FLOAT,
    discount FLOAT,
    price FLOAT,
    quantity INT,
    sold INT,
    defective INT,
    available INT,
    created TIMESTAMP,
    updated TIMESTAMP,
    updated_by int
) RETURNS VOID AS $$

BEGIN
    INSERT INTO item(
        supplier_id,
        sku,
        restock_url,
        msrp,
        discount,
        price,
        quantity,
        sold,
        defective,
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
        sold,
        defective,
        available,
        created,
        updated,
        updated_by
    );


END;
$$ language plpgsql