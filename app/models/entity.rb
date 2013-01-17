# == Schema Information
#
# Table name: entities
#
#  id                  :integer          not null, primary key
#  name                :string(255)      not null
#  content             :string(255)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  slug                :string(255)      not null
#  avatar_file_name    :string(255)
#  avatar_content_type :string(255)
#  avatar_file_size    :integer
#  avatar_updated_at   :datetime
#  wikipedia_hits      :integer          default(0)
#  link_karma          :integer          default(0)
#  comment_karma       :integer          default(0)
#

class Entity < ActiveRecord::Base
  before_save { |entity| entity.slug = entity.slug.parameterize }

  def to_param
    slug
  end

  has_attached_file :avatar, :styles => {:medium => "230x230#", :thumb => "100x100#"}
  attr_accessible :content, :name, :slug, :tag_list, :avatar, :wikipedia_hits, :link_karma, :comment_karma, :entities_links_attributes
  validates_presence_of :name, :slug
  validates_uniqueness_of :slug

  has_and_belongs_to_many :users
  has_many :entities_links, :dependent => :destroy
  accepts_nested_attributes_for :entities_links, :reject_if => lambda { |a| a[:link].blank? }, :allow_destroy => true

  acts_as_taggable
  has_paper_trail :ignore => [:updated_at, :wikipedia_hits, :comment_karma, :link_karma, :tag_list]
end
