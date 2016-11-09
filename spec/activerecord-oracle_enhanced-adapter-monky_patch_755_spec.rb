class Book < ActiveRecord::Base; end

describe ActiveRecord::Base do
  let(:book) { Book.first }

  before do
    ActiveRecord::Schema.define do
      create_table :books do |t|
        t.timestamps
      end
    end

    Book.create
  end

  describe '.find_by' do
    subject { Book.find_by(created_at: book.created_at) }

    it { is_expected.to eq book }
  end

  describe '.where' do
    subject { Book.where(created_at: book.created_at) }

    it { expect(subject.first).to eq book }
  end

  after do
    ActiveRecord::Schema.define do
      drop_table :books
    end
  end
end
