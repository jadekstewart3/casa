require "rails_helper"

RSpec.describe "/volunteers/notes", type: :request do
  describe "POST /create" do
    context "when logged in as admin" do
      it "can create a note for volunteer in same organization" do
        organization = create(:casa_org)
        admin = create(:casa_admin, casa_org: organization)
        volunteer = create(:volunteer, :with_assigned_supervisor, casa_org: organization)
        sign_in admin
        expect{
          post volunteer_notes_path(volunteer), params: {note: {content: "Very nice!"}}
        }.to change(Note, :count).by(1)
        expect(response).to redirect_to edit_volunteer_path(volunteer)
        expect(Note.last.content).to eq "Very nice!"
      end

      it "cannot create a note for volunteer in different organization" do
        organization = create(:casa_org)
        other_organization = create(:casa_org)
        admin = create(:casa_admin, casa_org: organization)
        volunteer = create(:volunteer, casa_org: other_organization)

        sign_in admin
        expect{
          post volunteer_notes_path(volunteer), params: {note: {content: "Very nice!"}}
        }.to_not change(Note, :count)
        expect(response).to redirect_to root_path
      end
    end

    context "when logged in as a supervisor" do
      it "can create a note for volunteer in same organization" do
        organization = create(:casa_org)
        supervisor = create(:supervisor, casa_org: organization)
        volunteer = create(:volunteer, :with_assigned_supervisor, casa_org: organization)
        sign_in supervisor
        expect{
          post volunteer_notes_path(volunteer), params: {note: {content: "Very nice!"}}
        }.to change(Note, :count).by(1)
        expect(response).to redirect_to edit_volunteer_path(volunteer)
        expect(Note.last.content).to eq "Very nice!"
      end

      it "cannot create a note for volunteer in different organization" do
        organization = create(:casa_org)
        other_organization = create(:casa_org)
        supervisor = create(:supervisor, casa_org: organization)
        volunteer = create(:volunteer, casa_org: other_organization)

        sign_in supervisor
        expect{
          post volunteer_notes_path(volunteer), params: {note: {content: "Very nice!"}}
        }.to_not change(Note, :count)
        expect(response).to redirect_to root_path
      end
    end
  end

  describe "PATCH /update" do
    context "when logged in as an admin" do
      context "with valid params" do
        it "redirects to edit volunteer page and updates note" do
          organization = create(:casa_org)
          admin = create(:casa_admin, casa_org: organization)
          volunteer = create(:volunteer, :with_assigned_supervisor, casa_org: organization)
          note = create(:note, notable: volunteer, creator: admin, content: "Good job.")

          sign_in admin
          patch volunteer_note_path(volunteer, note), params: {note: {content: "Very nice!"}}

          expect(response).to redirect_to(edit_volunteer_path(volunteer))
          expect(note.reload.content).to eq "Very nice!"
        end
      end
    end
  end

  describe "DELETE /destroy" do
    context "when logged in as an admin" do
      it "can delete notes about a volunteer" do
        organization = create(:casa_org)
        admin = create(:casa_admin, casa_org: organization)
        volunteer = create(:volunteer, :with_assigned_supervisor, casa_org: organization)
        note = create(:note, creator: admin, notable: volunteer)

        sign_in admin
        expect {
          delete volunteer_note_path(volunteer, note)
        }.to change(Note, :count).by(-1)
      end
    end

    context "when logged in as a supervisor" do
      it "can delete notes about a volunteer" do
        organization = create(:casa_org)
        supervisor = create(:supervisor, casa_org: organization)
        other_supervisor = create(:supervisor, casa_org: organization)
        volunteer = create(:volunteer, :with_assigned_supervisor, casa_org: organization)
        note = create(:note, creator: other_supervisor, notable: volunteer)

        sign_in supervisor
        expect {
          delete volunteer_note_path(volunteer, note)
        }.to change(Note, :count).by(-1)
      end
    end
  end
end
