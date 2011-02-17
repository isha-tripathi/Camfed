require 'spec_helper'
require 'controllers/authentication_helper'
# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by the Rails when you ran the scaffold generator.

describe ObjectMappingsController do
  before(:each) do
    sign_on
  end
  
  describe 'modify' do
    it 'should populate survey and object mapping' do
      survey = EpiSurveyor::Survey.new(:id => 1)
      EpiSurveyor::Survey.should_receive(:find).with("1").and_return(survey)
      
      an_object = Salesforce::Base.new(:name => 'a_name', :label => 'a label')
      Salesforce::Base.should_receive(:where).with(:display => true).and_return([an_object])
      
      get :modify, :survey_id => "1"
      response.should be_success
      assigns[:survey].should == survey
      assigns[:object_mapping].should_not be nil
      assigns[:sf_object_types].should have(1).things
      assigns[:sf_object_types].should == [an_object]
    end
  end
  
  describe 'create' do
    it 'should create the mapping' do
      post :create, :object_mapping => {:survey_id => 1, :sf_object_type => "Monitoring_Visit__c"}
      assigns[:object_mapping].survey_id.should == 1
      assigns[:object_mapping].sf_object_type.should == "Monitoring_Visit__c"
      response.should redirect_to new_object_mapping_field_mapping_path(assigns[:object_mapping])
    end
    
    it 'should reuse an existing mapping' do
      params = {:object_mapping => {:survey_id => 1, :sf_object_type => "Monitoring_Visit__c"}}
      ObjectMapping.create(params[:object_mapping])
      post :create, params
      ObjectMapping.where(params[:object_mapping]).should have(1).things
      response.should redirect_to new_object_mapping_field_mapping_path(assigns[:object_mapping].id)
    end
    
    it 'should redirect to modify if no salesforce object was selected' do
      params = {:survey_id => 1}
      post :create, params
      response.should redirect_to modify_survey_object_mappings_path(1)
      flash[:error].should == 'Please select a salesforce object to proceed'
    end
  end
  
  describe 'update' do
    it 'should update a record when it exists' do
      params = {:object_mapping => {:field_mappings_attributes => {
                                      "0" => {:field_name => "a_field", :question_name => 'a_question'},
                                      "1" => {:field_name => "b_field", :question_name => ''}
                                      }
                                    }
                }

      mapping = ObjectMapping.create(:survey_id => 1, :sf_object_type => 'AnObject')
      put :update, :id => mapping.id, :object_mapping => params[:object_mapping]
      mapping.reload
      mapping.field_mappings.first.field_name.should == 'a_field'
      mapping.field_mappings.should have(1).things
    end
  end
  
  describe 'destroy' do
    it 'should delete an existing object_mapping' do
      survey = EpiSurveyor::Survey.new(:name => 'a survey', :id => 2)
      object_mapping = ObjectMapping.new
      object_mapping.survey = survey
      ObjectMapping.should_receive(:find).with(1).and_return(object_mapping)
      object_mapping.should_receive(:destroy)
      delete :destroy, :id => 1
      response.should redirect_to survey_mappings_path(survey)
    end
  end
  
end
