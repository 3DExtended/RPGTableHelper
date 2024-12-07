using AutoMapper;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.NoteEntities;
using RPGTableHelper.WebApi.Dtos.RpgEntities;

namespace RPGTableHelper.WebApi.Services
{
    public class ListOfAbstractBaseTypeConverter<TAbstract, TImpl> : IValueConverter<IList<TAbstract>, IList<TImpl>>
        where TAbstract : class
        where TImpl : TAbstract
    {
        public IList<TImpl> Convert(IList<TAbstract> source, ResolutionContext context)
        {
            if (source == null)
            {
                return new List<TImpl>();
            }

            return source.OfType<TImpl>().ToList();
        }
    }

    public class ApiDtoMapperProfile : Profile
    {
        public ApiDtoMapperProfile()
        {
            CreateMap<NoteDocumentDto, NoteDocument>()
                .ForMember(dest => dest.NoteBlocks, opt => opt.MapFrom(src => MapNoteBlocks(src)));

            CreateMap<NoteDocument, NoteDocumentDto>()
                .ForMember(
                    x => x.ImageBlocks,
                    opt =>
                        opt.ConvertUsing(
                            new ListOfAbstractBaseTypeConverter<NoteBlockModelBase, ImageBlock>(),
                            x => x.NoteBlocks
                        )
                )
                .ForMember(
                    x => x.TextBlocks,
                    opt =>
                        opt.ConvertUsing(
                            new ListOfAbstractBaseTypeConverter<NoteBlockModelBase, TextBlock>(),
                            x => x.NoteBlocks
                        )
                );
        }

        private static IList<NoteBlockModelBase> MapNoteBlocks(NoteDocumentDto dto)
        {
            var noteBlocks = new List<NoteBlockModelBase>();
            if (dto.ImageBlocks != null)
            {
                noteBlocks.AddRange(dto.ImageBlocks);
            }

            if (dto.TextBlocks != null)
            {
                noteBlocks.AddRange(dto.TextBlocks);
            }

            return noteBlocks;
        }
    }
}
