# frozen_string_literal: true

require 'spec_helper'
require 'bunny'

module BunnyRun
  RSpec.describe Message do
    let(:delivery_mode) { 2 }
    let(:delivery_tag) { rand(1000) }
    let(:routing_key) { 'ping' }

    let(:channel) do
      instance_double(::Bunny::Channel, ack: nil, reject: nil)
    end

    let(:consumer) do
      instance_double(::Bunny::Consumer, no_ack: false)
    end

    let(:delivery_info) do
      instance_double(
        ::Bunny::DeliveryInfo,
        channel: channel,
        consumer: consumer,
        delivery_tag: delivery_tag,
        routing_key: routing_key
      )
    end

    let(:properties) do
      instance_double(
        ::Bunny::MessageProperties,
        delivery_mode: delivery_mode
      )
    end

    let(:payload) do
      '{"hello": "world"}'
    end

    describe '#delivery_info' do
      it 'returns message delivery_info' do
        msg = Message.new(delivery_info, properties, payload)

        result = msg.delivery_info

        expect(result).to eq(delivery_info)
      end
    end

    describe '#properties' do
      it 'returns message properties' do
        msg = Message.new(delivery_info, properties, payload)

        result = msg.properties

        expect(result).to eq(properties)
      end
    end

    describe '#payload' do
      it 'returns message payload' do
        msg = Message.new(delivery_info, properties, payload)

        result = msg.payload

        expect(result).to eq(payload)
      end
    end

    describe '#channel' do
      it 'returns channel from delivery_info' do
        msg = Message.new(delivery_info, properties, payload)

        result = msg.channel

        expect(result).to eq(channel)
      end
    end

    describe '#acked?' do
      it 'returns false when message has not been acked' do
        msg = Message.new(delivery_info, properties, payload)

        result = msg.acked?

        expect(result).to eq(false)
      end

      it 'returns true when message has been acked' do
        msg = Message.new(delivery_info, properties, payload)
        msg.ack

        result = msg.acked?

        expect(result).to eq(true)
      end

      it 'returns nil when message does not use manual ack' do
        allow(consumer).to receive(:no_ack).and_return(true)
        msg = Message.new(delivery_info, properties, payload)

        result = msg.acked?

        expect(result).to eq(nil)
      end
    end

    describe '#ack' do
      it 'acknowledges the message' do
        msg = Message.new(delivery_info, properties, payload)

        msg.ack

        expect(channel).to have_received(:ack).with(delivery_tag)
      end

      it 'makes #acked? return true' do
        msg = Message.new(delivery_info, properties, payload)
        expect(msg.acked?).to eq(false)

        msg.ack

        expect(msg.acked?).to eq(true)
      end
    end

    describe '#reject' do
      it 'rejects the message' do
        msg = Message.new(delivery_info, properties, payload)

        msg.reject

        expect(channel).to have_received(:reject).with(delivery_tag, false)
      end

      it 'makes #acked? return true' do
        msg = Message.new(delivery_info, properties, payload)
        expect(msg.acked?).to eq(false)

        msg.reject

        expect(msg.acked?).to eq(true)
      end
    end

    describe '#requeue' do
      it 'requeues the message' do
        msg = Message.new(delivery_info, properties, payload)

        msg.requeue

        expect(channel).to have_received(:reject).with(delivery_tag, true)
      end

      it 'makes #acked? return true' do
        msg = Message.new(delivery_info, properties, payload)
        expect(msg.acked?).to eq(false)

        msg.requeue

        expect(msg.acked?).to eq(true)
      end
    end

    describe '#manual_ack?' do
      it 'returns true when consumer is not "no_ack"' do
        allow(consumer).to receive(:no_ack).and_return(false)
        msg = Message.new(delivery_info, properties, payload)

        result = msg.manual_ack?

        expect(result).to eq(true)
      end

      it 'returns false when consumer is "no_ack"' do
        allow(consumer).to receive(:no_ack).and_return(true)
        msg = Message.new(delivery_info, properties, payload)

        result = msg.manual_ack?

        expect(result).to eq(false)
      end
    end

    describe '#routing_key' do
      it 'returns the routing key from delivery_info' do
        msg = Message.new(delivery_info, properties, payload)

        result = msg.routing_key

        expect(result).to eq(routing_key)
      end
    end

    describe '#delivery_mode' do
      it 'returns the routing key from message properties' do
        msg = Message.new(delivery_info, properties, payload)

        result = msg.delivery_mode

        expect(result).to eq(delivery_mode)
      end
    end

    describe '#delivery_tag' do
      it 'returns the delivery tag from delivery_info' do
        msg = Message.new(delivery_info, properties, payload)

        result = msg.delivery_tag

        expect(result).to eq(delivery_tag)
      end
    end
  end
end
