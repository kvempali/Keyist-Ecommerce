import { Configuration } from './model';


export const config: Configuration = {
  apiUrl: 'http://resource_service:8080',
  authUrl: 'http://auth_service:8081',
  clientId: 'test',
  clientSecret: 'test',
  carausel: [
    {
      title: 'Title',
      text: 'Text',
      imageUrl: ''
    },
    {
      title: 'Title',
      text: 'Text',
      imageUrl: ''
    },
    {
      title: 'Title',
      text: 'Text',
      imageUrl: ''
    }
  ],
  bannerUrl: ''
};
