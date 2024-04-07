import { Configuration } from './model';


export const config: Configuration = {
  apiUrl: 'http://resource_server:8080',
  authUrl: 'http://authorization_server:8081',
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
