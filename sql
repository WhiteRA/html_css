CREATE OR REPLACE FUNCTION delete_user_info(user_id_to_delete INTEGER) RETURNS INTEGER AS $$
DECLARE
    user_id INTEGER;
BEGIN
    -- Получаем user_id пользователя
    SELECT id INTO user_id FROM vk.users WHERE id = user_id_to_delete;

    -- Удаляем сообщения
    DELETE FROM vk.messages WHERE user_id = user_id_to_delete;

    -- Удаляем лайки
    DELETE FROM vk.likes WHERE user_id = user_id_to_delete;

    -- Удаляем медиа записи
    DELETE FROM vk.media WHERE user_id = user_id_to_delete;

    -- Удаляем профиль
    DELETE FROM vk.profiles WHERE user_id = user_id_to_delete;

    -- Удаляем запись из таблицы users
    DELETE FROM vk.users WHERE id = user_id_to_delete;

    -- Возвращаем номер пользователя
    RETURN user_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE delete_user_info_transaction(user_id_to_delete INTEGER) AS $$
BEGIN
    -- Начало транзакции
    BEGIN;
    
    -- Вызываем функцию для удаления информации о пользователе
    PERFORM delete_user_info(user_id_to_delete);
    
    -- Коммит транзакции
    COMMIT;
EXCEPTION
    -- Обработка ошибок
    WHEN OTHERS THEN
        -- Откат транзакции в случае ошибки
        ROLLBACK;
        -- Ретранслируем исключение
        RAISE;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION check_community_name_length() RETURNS TRIGGER AS $$
BEGIN
    IF LENGTH(NEW.name) < 5 THEN
        RAISE EXCEPTION 'Name length of the community should be at least 5 characters.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_community_name_length_trigger
BEFORE INSERT OR UPDATE ON vk.communities
FOR EACH ROW
EXECUTE FUNCTION check_community_name_length();
