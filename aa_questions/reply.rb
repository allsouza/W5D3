require_relative 'questions_db_connect'
require_relative 'god'
require_relative 'user'
require_relative 'question'
require_relative 'question_follow'
require_relative 'question_like'

class Reply < God
    attr_accessor :id, :parent_id, :question_id, :user_id, :body
    def self.all
      data = super('replies')
      data.map { |datum| Reply.new(datum) }
    end

    def self.find_by_id(id)
      reply = super('replies', id)
      return nil if reply.length < 1
      Reply.new(reply.first)
    end
    
    def self.where(options)
      reply = super('replies', options)
      raise "not in database" if reply.length < 1
      Reply.new(reply.first)
    end

    def self.find_by_user_id(id)
        replies = QuestionDBConnection.instance.execute(<<-SQL, id) 
            SELECT
              * 
            FROM
              replies
            WHERE
              user_id = ?
        SQL
        return nil unless replies.length > 0
        replies.map { |reply| Reply.new(reply) }
    end

    def self.find_by_question_id(id)
      replies = QuestionDBConnection.instance.execute(<<-SQL, id) 
          SELECT
            * 
          FROM
            replies
          WHERE
            question_id = ?
      SQL
      return nil unless replies.length > 0
      replies.map { |reply| Reply.new(reply) }
    end

    def initialize(options)
        super(options['id'])
        @parent_id = options['parent_id']
        @question_id = options['question_id']
        @user_id = options['user_id']
        @body = options['body']
    end

    def create
      raise "#{self} already exists in database" if self.id
      QuestionDBConnection.instance.execute(<<-SQL, self.parent_id, self.question_id, self.user_id, self.body)
        INSERT INTO
          replies (parent_id, question_id, user_id, body)
        VALUES
          (?, ?, ?, ?)
      SQL
      self.id = QuestionDBConnection.instance.last_insert_row_id
    end

    def update
      raise "#{self} does not exist in database" unless self.id
      QuestionDBConnection.instance.execute(<<-SQL, self.parent_id, self.question_id, self.user_id, self.body)
        UPDATE
          replies
        SET
          parent_id = ?, question_id = ?, user_id = ?, body = ?
        WHERE
          id = ?
      SQL
    end

    def author
        author = QuestionDBConnection.instance.execute(<<-SQL, self.user_id)
            SELECT
            *
            FROM
            users
            WHERE
            users.id = ?
        SQL
        User.new(author.first)
    end

    def question
        Question.find_by_id(self.question_id)
    end

    def parent_reply
        reply = QuestionDBConnection.instance.execute(<<-SQL, self.parent_id)
            SELECT
                *
            FROM
                replies
            WHERE
                id = ?
        SQL
        return nil if reply.length < 1
        Reply.new(reply.first)
    end

    def child_replies
        replies = QuestionDBConnection.instance.execute(<<-SQL, self.id)
        SELECT
            *
        FROM
            replies
        WHERE
            parent_id = ?
        SQL
        replies.map { |reply| Reply.new(reply) }
    end
end