class PropertySearchInput
  # Use the active model syntax for validating
  include   ActiveModel::Validations
  attr_accessor      :lat, :lng, :property_type, :marketing_type

  validates :lat,             presence: { message: 'is a required field' }, numericality: { message: 'should be a numeric value' }
  validates :lng,             presence: { message: 'is a required field' }, numericality: { message: 'should be a numeric value' }
  validates :marketing_type,  presence: { message: 'is a required field' }, inclusion: { in: %w(sell rent), message: 'should be rent or sell' }
  validates :property_type,   presence: { message: 'is a required field' }, inclusion: { in: %w(apartment single_family_house), message: 'should be apartment or single_family_house' }

  def initialize(args = {})
    args.each do |key, value|
      self.send("#{key}=", value) if self.respond_to? "#{key}="
    end
  end
end