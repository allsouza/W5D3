require_relative 'questions_db_connect'
require_relative 'user'
require_relative 'question'

class QuestionLike

  def self.likers_for_question_id(question_id)
    users = QuestionDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        users.*
      FROM
        question_likes JOIN users ON users.id = question_likes.user_id
      WHERE
        question_likes.question_id = ?
    SQL
    users.map { |user| User.new(user) }
  end

  def self.num_likes_for_question_id(question_id)
    QuestionDBConnection.instance.execute(<<-SQL, question_id)
        SELECT
            COUNT(users.id)
        FROM
            question_likes
            JOIN users ON
            question_likes.user_id = users.id
        WHERE
            question_likes.question_id = ?
    SQL
  end

  def self.liked_questions_for_user_id(user_id)
    questions = QuestionDBConnection.instance.execute(<<-SQL, user_id)
      SELECT
        questions.id, questions.title, questions.body, questions.user_id
      FROM
        question_likes JOIN questions ON questions.id = question_likes.question_id
      WHERE
        question_likes.user_id = ?
    SQL
    questions.map { |question| Question.new(question) }
  end

  def self.most_liked_questions(n)
    questions = QuestionDBConnection.instance.execute(<<-SQL, n)
    SELECT
        questions.*
    FROM
        question_likes
        JOIN questions ON
        questions.id = question_likes.question_id
    GROUP BY
        question_likes.question_id
    ORDER BY
        COUNT(question_likes.user_id) DESC
    LIMIT
        ?
    SQL
    questions.map { |question| Question.new(question) }
  end

end