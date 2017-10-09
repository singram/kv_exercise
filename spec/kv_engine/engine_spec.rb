require_relative '../../kv_engine/stack'
require_relative '../../kv_engine/field_stack'

[KvEngine::FieldStack, KvEngine::Stack].each do |engine_class|

  describe engine_class do

    let(:engine) {engine_class.new}

    before(:each) do
      allow(STDOUT).to receive(:puts)
    end

    describe '#initialize' do

      it 'will open a transaction' do
        expect(engine.send(:transaction_count)).to eq(1)
      end

    end

    describe '#read' do

      it "returns the value of an existing key" do
        engine.write(key: 'A', value: 2)
        expect(engine.read(key: 'A')).to eq(2)
      end

      it 'raises an error if the key does not exist' do
        expect{ engine.read(key: 'A') }.to raise_error(Exceptions::UnknownKey)
      end

      it 'raises an error if the key did exist but was deleted' do
        engine.write(key: 'A', value: 2)
        engine.delete(key: 'A')
        expect{ engine.read(key: 'A') }.to raise_error(Exceptions::UnknownKey)
      end

    end

    describe '#write' do

      it 'stores the value of a new key' do
        engine.write(key: 'A', value: 2)
        expect(engine.read(key: 'A')).to eq(2)
      end

      it 'overwrites the valye of an existing key' do
        engine.write(key: 'A', value: 2)
        engine.write(key: 'A', value: 3)
        expect(engine.read(key: 'A')).to eq(3)
      end

      it 'stores the value of a key that was previously deleted' do
        engine.write(key: 'A', value: 2)
        engine.delete(key: 'A')
        engine.write(key: 'A', value: 2)
        expect(engine.read(key: 'A')).to eq(2)
      end

    end

    describe '#delete' do

      it 'deletes an existing key from the store' do
        engine.write(key: 'A', value: 2)
        expect{ engine.delete(key: 'A') }.to_not raise_error
        expect{ engine.read(key: 'A') }.to raise_error(Exceptions::UnknownKey)
      end

      it 'does not error if the key does not exist' do
        expect{ engine.delete(key: 'A') }.to_not raise_error
      end

    end

    describe '#start' do

      it 'creates a new transaction' do
        expected_transaction_count = engine.send(:transaction_count) + 1
        expect{ engine.start }.to_not raise_error
        expect( engine.send(:transaction_count) ).to eq(expected_transaction_count)
      end

    end

    describe '#abort' do

      before(:each) do
        engine.write(key: 'A', value: 1)
        engine.write(key: 'B', value: 2)
        engine.write(key: 'C', value: 3)
        engine.start
        engine.write(key: 'A', value: 11)
        engine.write(key: 'B', value: 2)
        engine.delete(key: 'C')
        engine.write(key: 'D', value: 44)
      end

      it 'should discare the current transaction' do
        expected_transaction_count = engine.send(:transaction_count) - 1
        expect{ engine.abort }.to_not raise_error
        expect( engine.send(:transaction_count) ).to eq(expected_transaction_count)
      end

      it 'should not error if no transaction is open' do
        expect{ engine.abort }.to_not raise_error
        expect{ engine.abort }.to_not raise_error
        expect{ engine.abort }.to_not raise_error
        expect( engine.send(:transaction_count) ).to eq(0)
      end

      it 'should ignore noops' do
        engine.abort
        expect(engine.read(key: 'B')).to eq(2)
      end

      it 'should discard changes to existing keys' do
        engine.abort
        expect(engine.read(key: 'A')).to eq(1)
      end

      it 'should discard values for new keys' do
        engine.abort
        expect{ engine.read(key: 'D') }.to raise_error(Exceptions::UnknownKey)
      end

      it 'should discard deletes' do
        engine.abort
        expect(engine.read(key: 'C')).to eq(3)
      end

    end

    describe '#commit' do

      before(:each) do
        engine.write(key: 'A', value: 1)
        engine.write(key: 'B', value: 2)
        engine.write(key: 'C', value: 3)
      end

      it 'should close the current transaction' do
        expected_transaction_count = engine.send(:transaction_count) - 1
        expect{ engine.commit }.to_not raise_error
        expect( engine.send(:transaction_count) ).to eq(expected_transaction_count)
      end

      it 'should error if no transaction is open' do
        expect{ engine.commit }.to_not raise_error
        expect{ engine.commit }.to raise_error(Exceptions::NoOpenTransaction)
        expect( engine.send(:transaction_count) ).to eq(0)
      end

      it 'should persist noops' do
        engine.commit
        expect(engine.read(key: 'A')).to eq(1)
        expect(engine.read(key: 'B')).to eq(2)
        expect(engine.read(key: 'C')).to eq(3)
      end

      it 'should persist changes to existing keys' do
        engine.write(key: 'A', value: 11)
        engine.write(key: 'B', value: 22)
        engine.write(key: 'C', value: 33)
        engine.commit
        expect(engine.read(key: 'A')).to eq(11)
        expect(engine.read(key: 'B')).to eq(22)
        expect(engine.read(key: 'C')).to eq(33)
      end

      it 'should persist values for new keys' do
        engine.write(key: 'D', value: 4)
        engine.commit
        expect(engine.read(key: 'A')).to eq(1)
        expect(engine.read(key: 'B')).to eq(2)
        expect(engine.read(key: 'C')).to eq(3)
        expect(engine.read(key: 'D')).to eq(4)
      end

      it 'should persist deletes' do
        engine.delete(key: 'A')
        engine.delete(key: 'B')
        engine.delete(key: 'C')
        engine.commit
        expect{ engine.read(key: 'A') }.to raise_error(Exceptions::UnknownKey)
        expect{ engine.read(key: 'B') }.to raise_error(Exceptions::UnknownKey)
        expect{ engine.read(key: 'C') }.to raise_error(Exceptions::UnknownKey)
      end

    end


    describe 'Exercise test case' do

      it 'will pass the example sequence' do
        engine.write(key: 'a', value: 'hello')
        expect(engine.read(key: 'a')).to eq('hello')
        engine.start
        engine.write(key: 'a', value: 'hello-again')
        expect(engine.read(key: 'a')).to eq('hello-again')
        engine.start
        engine.delete(key: 'a')
        expect{ engine.read(key: 'a') }.to raise_error(Exceptions::UnknownKey)
        engine.commit
        expect{ engine.read(key: 'a') }.to raise_error(Exceptions::UnknownKey)
        engine.write(key: 'a', value: 'once-more')
        expect(engine.read(key: 'a')).to eq('once-more')
        engine.abort
        expect(engine.read(key: 'a')).to eq('hello')
      end

    end

  end
end
