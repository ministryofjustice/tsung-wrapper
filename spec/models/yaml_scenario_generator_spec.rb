require_relative '../spec_helper'
require_relative '../../lib/yaml_scenario_generator'

module TsungWrapper

  describe YamlScenarioGenerator do

    context 'generate_a_scenario_file' do
      it 'should generate a correct yaml file from a scenario hash read from a CSV file' do
        yaml = YamlScenarioGenerator.new(scenario_hash).to_yaml
        yaml.should == expected_yaml
      end
    end

  end

end



def scenario_hash
  {:title=>"JOURNEY 1",
 :description=>
  ["Husband and wife, renting a property through a rental agency",
   "2 claimants living together, 2 defendants living in the property, rental agency"],
 :claim=>
  {:property=>
    {:street=>"87 Albion St\nLeeds ", :postcode=>"LS1 6AG", :house=>"Yes"},
   :javascript=>
    {:number_of_claimants=>"2",
     :claimant_two_same_address=>"Yes",
     :any_legal_costs=>"No",
     :separate_correspondence_address=>"Yes",
     :other_contact_details=>"Yes",
     :add_reference_number=>"No",
     :number_of_defendants=>"2",
     :defendant_one_living_in_property=>"Yes",
     :defendent_two_living_in_property=>"Yes"},
   :claimant_one=>
    {:title=>"Mr ",
     :full_name=>"Matthew Collier",
     :street=>"2 Savins Mill Way\nLeeds",
     :postcode=>"LS5 3RP"},
   :claimant_two=>
    {:title=>"Mrs",
     :full_name=>"Violet Collier",
     :street=>nil,
     :postcode=>nil},
   :legal_cost=>{:legal_costs=>nil},
   :claimant_contact=>
    {:title=>"Mr ",
     :full_name=>"Robert Linley",
     :company_name=>"Linley & Simpson",
     :street=>"16 Swinegate\nLeeds",
     :postcode=>"LS1 4AG",
     :email=>"robertlinley@linleyandsimpson.com",
     :phone=>"0113 246 9295",
     :fax=>nil,
     :dx_number=>nil},
   :reference_number=>{:reference_number=>nil},
   :defendant_one=>
    {:title=>"Miss",
     :full_name=>"Virginia Richardson",
     :street=>nil,
     :postcode=>nil},
   :defendant_two=>
    {:title=>"Miss",
     :full_name=>"Maria Gonzalez",
     :street=>nil,
     :postcode=>nil},
   :tenancy=>
    {:tenancy_type=>"Assured",
     :assured_shorthold_tenancy_type=>"one",
     :original_assured_shorthold_tenancy_agreement_date=>nil,
     :start_date=>"2002-01-01",
     :latest_agreement_date=>nil,
     :agreement_reissued_for_same_property=>nil,
     :agreement_reissued_for_same_landlord_and_tenant=>nil,
     :assured_shorthold_tenancy_notice_served_by=>nil,
     :assured_shorthold_tenancy_notice_served_date=>nil,
     :demotion_order_date=>nil,
     :demotion_order_court=>nil,
     :previous_tenancy_type=>nil},
   :notice=>
    {:served_by_name=>"Robert Linley",
     :served_method=>"In person",
     :date_served=>"2014-01-13",
     :expiry_date=>"2014-03-13"},
   :license=>
    {:multiple_occupation=>"No",
     :issued_under_act_part=>nil,
     :issued_by=>nil,
     :issued_date=>nil},
   :deposit=>
    {:received=>"Yes",
     :information_given_date=>"2002-01-15",
     :ref_number=>"xtNHhYqYmL",
     :as_money=>"Yes",
     :as_property=>"No"},
   :order=>{:possession=>"Yes", :cost=>"No"},
   :possession=>{:hearing=>"No"}}}
end




def expected_yaml
yaml = <<-EOYAML
---
request:
  name: 
  url: "/submission"
  http_method: POST
  params:
    utf8: "✓"
    claim:
      :property:
        :street: "87 Albion St\\nLeeds "
        :postcode: LS1 6AG
        :house: 'Yes'
      :javascript:
        :number_of_claimants: '2'
        :claimant_two_same_address: 'Yes'
        :any_legal_costs: 'No'
        :separate_correspondence_address: 'Yes'
        :other_contact_details: 'Yes'
        :add_reference_number: 'No'
        :number_of_defendants: '2'
        :defendant_one_living_in_property: 'Yes'
        :defendent_two_living_in_property: 'Yes'
      :claimant_one:
        :title: 'Mr '
        :full_name: Matthew Collier
        :street: |-
          2 Savins Mill Way
          Leeds
        :postcode: LS5 3RP
      :claimant_two:
        :title: Mrs
        :full_name: Violet Collier
        :street: 
        :postcode: 
      :legal_cost:
        :legal_costs: 
      :claimant_contact:
        :title: 'Mr '
        :full_name: Robert Linley
        :company_name: Linley & Simpson
        :street: |-
          16 Swinegate
          Leeds
        :postcode: LS1 4AG
        :email: robertlinley@linleyandsimpson.com
        :phone: 0113 246 9295
        :fax: 
        :dx_number: 
      :reference_number:
        :reference_number: 
      :defendant_one:
        :title: Miss
        :full_name: Virginia Richardson
        :street: 
        :postcode: 
      :defendant_two:
        :title: Miss
        :full_name: Maria Gonzalez
        :street: 
        :postcode: 
      :tenancy:
        :tenancy_type: Assured
        :assured_shorthold_tenancy_type: one
        :original_assured_shorthold_tenancy_agreement_date: 
        :start_date: '2002-01-01'
        :latest_agreement_date: 
        :agreement_reissued_for_same_property: 
        :agreement_reissued_for_same_landlord_and_tenant: 
        :assured_shorthold_tenancy_notice_served_by: 
        :assured_shorthold_tenancy_notice_served_date: 
        :demotion_order_date: 
        :demotion_order_court: 
        :previous_tenancy_type: 
      :notice:
        :served_by_name: Robert Linley
        :served_method: In person
        :date_served: '2014-01-13'
        :expiry_date: '2014-03-13'
      :license:
        :multiple_occupation: 'No'
        :issued_under_act_part: 
        :issued_by: 
        :issued_date: 
      :deposit:
        :received: 'Yes'
        :information_given_date: '2002-01-15'
        :ref_number: xtNHhYqYmL
        :as_money: 'Yes'
        :as_property: 'No'
      :order:
        :possession: 'Yes'
        :cost: 'No'
      :possession:
        :hearing: 'No'
EOYAML
end

