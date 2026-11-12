import { plainToInstance } from 'class-transformer';
import { validate } from 'class-validator';
import { SubmitCompanyProfileResource } from './submit-company-profile.resource';

const completeCompanyProfile = {
  rucNumber: '20123456789',
  businessName: 'Tech Solutions SAC',
  industrySector: 'TECHNOLOGY',
  contactPhone: '+51 987654321',
  legalAddress: {
    street: 'Av. Los Constructores 456',
    city: 'Lima',
    state: 'Lima',
    postalCode: '15023',
    country: 'Perú',
  },
  rucDocumentUrl:
    'http://localhost:9100/vankoo-profile-documents/companies/1/ruc/ficha.pdf',
};

const validateSubmission = (body: object) =>
  validate(plainToInstance(SubmitCompanyProfileResource, body));

describe('SubmitCompanyProfileResource', () => {
  it('accepts a complete profile with its ficha RUC', async () => {
    const errors = await validateSubmission(completeCompanyProfile);

    expect(errors).toHaveLength(0);
  });

  it.each([undefined, ''])(
    'asks for the ficha RUC when rucDocumentUrl is %p',
    async (rucDocumentUrl) => {
      const errors = await validateSubmission({
        ...completeCompanyProfile,
        rucDocumentUrl,
      });

      expect(errors).toHaveLength(1);
      expect(errors[0].property).toBe('rucDocumentUrl');
      expect(errors[0].constraints?.isNotEmpty).toBe('Falta la ficha RUC');
    },
  );
});
