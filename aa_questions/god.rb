require_relative 'questions_db_connect'

class God

    def self.all(table)
        QuestionDBConnection.instance.execute(<<-SQL)
            SELECT * 
            FROM #{table}
        SQL
    end

    def self.find_by_id(table, id)
        QuestionDBConnection.instance.execute(<<-SQL, id)
        SELECT
          * 
        FROM
          #{table}
        WHERE
          id = ?
        SQL
    end

    # def self.where(table, options)
    #   col, value = options.keys[0], options.values[0]
    #   QuestionDBConnection.instance.execute(<<-SQL, value)
    #   SELECT
    #     *
    #   FROM
    #     #{table}
    #   WHERE
    #     #{col} = ?
    #   SQL
    # end

    def self.where(table, options)
      QuestionDBConnection.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table}
      WHERE
        #{options}
      SQL
    end

    def initialize(id)
        @id = id
    end

    def save
        self.id ? self.update : self.create
    end

end